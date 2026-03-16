import type { Command } from "commander";
import pc from "picocolors";
import {
  startRaw, wordWrap,
  truncVis, padTo, visWidth, stripAnsi, input,
  mkScroll, columnsNav, appShell, handleStdKey,
  columnWidths,
  type Keys, type Scroll, type PanelDef,
} from "../lib/tui.ts";
import * as searchLib from "../lib/search.ts";
import * as transmission from "../lib/transmission.ts";
import * as omdb from "../lib/omdb.ts";
import * as tmdb from "../lib/tmdb.ts";
import { regenerate } from "../lib/tropes.ts";
import {
  saveItem, upsertRating, removeRating, addToWatchlist, removeFromWatchlist,
  getRatings, getWatchlist, getPrefs, getRatingForImdb,
  getProfiles, createProfile, getActiveProfileIds, setActiveProfileIds,
  getTropes, getItemsForTrope, deleteTrope, getLastRegenTime,
  profileKey, getItemInfo, db,
  type Profile, type Trope,
} from "../lib/db.ts";
import { truncate, fmtSpeed, fmtEta, progressBar, stars } from "../lib/interactive.ts";
import { config } from "../lib/config.ts";

// state

type Tab = "lists" | "explore" | "search" | "torrent";
const TAB_ORDER: Tab[] = ["lists", "explore", "search", "torrent"];

interface ListItem {
  title: string;
  year: string | null;
  type: string | null;
  genre: string | null;
  imdb_id: string;
  rating: number | null; // null = unrated, number = rating (or avg for group)
  onWatchlist: boolean;
  profile_id: number; // owning profile (for watchlist removal)
}

// profile helpers

function activeIds(s: State): number[] {
  return s.activeProfiles.map(p => p.id);
}

function isGroup(s: State): boolean {
  return s.activeProfiles.length > 1;
}

function profileName(s: State, id: number): string {
  return s.profiles.find(p => p.id === id)?.name ?? "?";
}

// list helpers

function buildList(s: State): ListItem[] {
  const ids = activeIds(s);
  const wl = getWatchlist(ids);
  const rat = getRatings(ids);
  const group = isGroup(s);

  // build map of imdb_id -> aggregated item
  const map = new Map<string, ListItem>();

  for (const w of wl) {
    const existing = map.get(w.imdb_id);
    if (!existing) {
      map.set(w.imdb_id, {
        title: w.title, year: w.year, type: w.type, genre: w.genre,
        imdb_id: w.imdb_id, rating: null, onWatchlist: true, profile_id: w.profile_id,
      });
    }
  }

  // aggregate ratings: single profile = direct, group = average
  const ratingsByImdb = new Map<string, number[]>();
  for (const r of rat) {
    let arr = ratingsByImdb.get(r.imdb_id);
    if (!arr) { arr = []; ratingsByImdb.set(r.imdb_id, arr); }
    arr.push(r.rating);
  }

  for (const [imdbId, ratings] of ratingsByImdb) {
    const avg = group
      ? Math.round(ratings.reduce((a, b) => a + b, 0) / ratings.length)
      : ratings[0];
    const existing = map.get(imdbId);
    if (existing) {
      existing.rating = avg;
    } else {
      const r = rat.find(x => x.imdb_id === imdbId)!;
      map.set(imdbId, {
        title: r.title, year: r.year, type: r.type, genre: r.genre,
        imdb_id: imdbId, rating: avg, onWatchlist: false, profile_id: r.profile_id,
      });
    }
  }

  // sort: watchlist first, then by genre match, then alphabetical
  const items = [...map.values()];
  items.sort((a, b) => {
    if (a.onWatchlist !== b.onWatchlist) return a.onWatchlist ? -1 : 1;
    if (s.genreSelected.size) {
      const diff = genreMatchCount(b.genre, s.genreSelected) - genreMatchCount(a.genre, s.genreSelected);
      if (diff !== 0) return diff;
    }
    return a.title.localeCompare(b.title);
  });
  return items;
}

// genre helpers

function allGenres(profileIds?: number[]): string[] {
  const seen = new Set<string>();
  for (const r of getRatings(profileIds)) {
    if (r.genre) r.genre.split(",").map(g => g.trim()).filter(Boolean).forEach(g => seen.add(g));
  }
  for (const w of getWatchlist(profileIds)) {
    if (w.genre) w.genre.split(",").map(g => g.trim()).filter(Boolean).forEach(g => seen.add(g));
  }
  return [...seen].sort();
}

function genreMatchCount(genre: string | null | undefined, selected: Set<string>): number {
  if (!selected.size || !genre) return 0;
  const tags = genre.split(",").map(g => g.trim());
  return tags.filter(g => selected.has(g)).length;
}

function parseGenres(genre: string | null | undefined): string[] {
  if (!genre) return [];
  return genre.split(",").map(g => g.trim()).filter(Boolean);
}


interface State {
  tab: Tab;
  prompt: string;
  promptActive: boolean;
  status: string;

  // genres
  genres: string[];
  genreSelected: Set<string>;
  genreMode: boolean;
  genreCursor: number;
  genrePending: Set<string>;
  genreScroll: number;

  // recommend
  tropes: Trope[];
  tropeCursor: number;
  tropePreview: ListItem[];   // right pane preview when hovering trope list
  tropeItems: ListItem[];
  tropeItemCursor: number;
  tropeInfo: omdb.OmdbItem | null;
  tropeView: "tropes" | "items";
  tropeSearchResults: omdb.SearchResult[];
  tropeSearchCursor: number;
  tropeSearchLoading: boolean;
  regenLoading: boolean;
  regenStatus: string;

  // lists
  listCursor: number;
  listInfo: omdb.OmdbItem | null;

  // search
  searchResults: searchLib.Result[];
  searchCursor: number;
  searchLoading: boolean;
  searchBest: number;

  // torrent
  torrents: transmission.Torrent[];
  dlCursor: number;
  dlDetail: transmission.TorrentDetail | null;
  dlFileCursor: number;
  torrentSearch: boolean;

  // navigation
  pane: "left" | "right";
  leftScroll: Scroll;
  rightScroll: Scroll;
  rightLineCount: number;

  // streaming
  streamingCache: Map<string, tmdb.WatchInfo>;

  // profiles
  profiles: Profile[];
  activeProfiles: Profile[];
  profileMode: boolean;
  profileCursor: number;
  profilePending: Set<number>;
}

function initState(): State {
  const allProfiles = getProfiles();
  const savedIds = getActiveProfileIds();
  const active = savedIds
    ? allProfiles.filter(p => savedIds.includes(p.id))
    : allProfiles.slice(0, 1);
  const activeOrFallback = active.length ? active : allProfiles.slice(0, 1);
  return {
    tab: "lists", prompt: "", promptActive: false, status: "",
    genres: allGenres(activeOrFallback.map(p => p.id)), genreSelected: new Set(), genreMode: false, genreCursor: 0, genrePending: new Set(), genreScroll: 0,
    tropes: [], tropeCursor: 0, tropePreview: [], tropeItems: [], tropeItemCursor: 0,
    tropeInfo: null, tropeView: "tropes", tropeSearchResults: [], tropeSearchCursor: 0, tropeSearchLoading: false, regenLoading: false, regenStatus: "",
    listCursor: 0, listInfo: null,
    searchResults: [], searchCursor: 0, searchLoading: false, searchBest: -1,
    torrents: [], dlCursor: 0, dlDetail: null, dlFileCursor: 0, torrentSearch: false,
    pane: "left" as const,
    leftScroll: mkScroll(), rightScroll: mkScroll(), rightLineCount: 0, streamingCache: new Map(),
    profiles: allProfiles,
    activeProfiles: activeOrFallback,
    profileMode: false,
    profileCursor: 0,
    profilePending: new Set(activeOrFallback.map(p => p.id)),
  };
}

// heuristics

function bestResultIndex(results: searchLib.Result[]): number {
  const candidates = results
    .map((r, i) => ({ r, i }))
    .filter(({ r }) => r.seeds >= 100 && /1080/.test(r.title));
  if (!candidates.length) return 0;
  candidates.sort((a, b) => a.r.bytes - b.r.bytes);
  return candidates[0].i;
}

function detectEpisodes(files: transmission.TorrentFile[]): { ep: number; idx: number }[] {
  return files
    .map((f, i) => {
      const m = f.name.match(/[Ss]\d+[Ee](\d+)/);
      return m ? { ep: parseInt(m[1]), idx: i } : null;
    })
    .filter(Boolean) as { ep: number; idx: number }[];
}

async function autoSelectEpisodes(id: number, files: transmission.TorrentFile[]) {
  const eps = detectEpisodes(files);
  if (eps.length < 3) return;
  eps.sort((a, b) => a.ep - b.ep);
  const wanted = eps.slice(0, 2).map(e => e.idx);
  const unwanted = eps.slice(2).map(e => e.idx);
  await transmission.setFilesWanted(id, wanted, unwanted);
}

function openTrailer(title: string, year?: string) {
  const q = encodeURIComponent(`${title} ${year ?? ""} trailer`.trim());
  Bun.spawn(["xdg-open", `https://www.youtube.com/results?search_query=${q}`], { stdout: "ignore", stderr: "ignore" });
}

const PROVIDER_URLS: Record<string, string> = {
  "Netflix": "https://www.netflix.com/search?q=",
  "Amazon Prime Video": "https://www.amazon.com/s?i=instant-video&k=",
  "Disney Plus": "https://www.disneyplus.com/search/",
  "Apple TV": "https://tv.apple.com/search?term=",
  "Apple TV Plus": "https://tv.apple.com/search?term=",
  "HBO Max": "https://play.max.com/search?q=",
  "Max": "https://play.max.com/search?q=",
  "Hulu": "https://www.hulu.com/search?q=",
  "Paramount Plus": "https://www.paramountplus.com/search/",
  "Peacock": "https://www.peacocktv.com/search?q=",
  "Mubi": "https://mubi.com/search?query=",
  "Crunchyroll": "https://www.crunchyroll.com/search?q=",
  "YouTube": "https://www.youtube.com/results?search_query=",
  "Google Play Movies": "https://play.google.com/store/search?q=",
};

function openProvider(imdbId: string, fIdx: number, title: string, s: State) {
  const info = s.streamingCache.get(imdbId);
  if (!info?.providers[fIdx]) return;
  const p = info.providers[fIdx];
  const base = PROVIDER_URLS[p.name];
  if (base) {
    Bun.spawn(["xdg-open", base + encodeURIComponent(title)], { stdout: "ignore", stderr: "ignore" });
  } else if (info.link) {
    Bun.spawn(["xdg-open", info.link], { stdout: "ignore", stderr: "ignore" });
  }
}

// async actions

let debounceTimer: ReturnType<typeof setTimeout> | null = null;

function tropeItemList(tropeId: number, s: State): ListItem[] {
  const ids = activeIds(s);
  const rated = new Set(getRatings(ids).map(r => r.imdb_id));
  const watchlisted = new Set(getWatchlist(ids).map(w => w.imdb_id));
  return getItemsForTrope(tropeId)
    .filter(it => !rated.has(it.imdb_id) && !watchlisted.has(it.imdb_id))
    .filter(it => !s.genreSelected.size || genreMatchCount(it.genre, s.genreSelected) > 0)
    .slice(0, 10)
    .map(it => ({
      title: it.title,
      year: it.year,
      type: it.type,
      genre: it.genre,
      imdb_id: it.imdb_id,
      rating: null,
      onWatchlist: false,
      profile_id: 0,
    }));
}

function loadTropePreview(s: State) {
  const trope = s.tropes[s.tropeCursor];
  s.tropePreview = trope ? tropeItemList(trope.id, s) : [];
}

function loadTropes(s: State) {
  const pKey = profileKey(activeIds(s));
  const ids = activeIds(s);
  const rated = new Set(getRatings(ids).map(r => r.imdb_id));
  const watchlisted = new Set(getWatchlist(ids).map(w => w.imdb_id));
  s.tropes = getTropes(pKey).map(t => {
    const items = getItemsForTrope(t.id);
    const unseen = items
      .filter(it => !rated.has(it.imdb_id) && !watchlisted.has(it.imdb_id))
      .filter(it => !s.genreSelected.size || genreMatchCount(it.genre, s.genreSelected) > 0);
    return { ...t, item_count: unseen.length };
  }).filter(t => (t.item_count ?? 0) > 0)
    .sort((a, b) => (b.item_count ?? 0) - (a.item_count ?? 0));
  s.tropeCursor = 0;
  s.tropePreview = [];
  s.tropeItems = [];
  s.tropeItemCursor = 0;
  s.tropeInfo = null;
  s.tropeView = "tropes";
  loadTropePreview(s);
}

function triggerRegen(s: State, draw: () => void) {
  if (s.regenLoading) return;
  s.regenLoading = true;
  s.regenStatus = "Generating tropes...";
  draw();

  const ids = activeIds(s);
  const genreFilter = s.genreSelected.size
    ? [...s.genreSelected].join(", ")
    : undefined;

  regenerate(ids, genreFilter, (msg) => {
    s.regenStatus = msg;
    draw();
  })
    .then(() => {
      loadTropes(s);
      s.regenStatus = "";
    })
    .catch(() => { s.regenStatus = "Trope generation failed"; })
    .finally(() => { s.regenLoading = false; draw(); });
}

function lazyRegen(s: State, draw: () => void) {
  const pKey = profileKey(activeIds(s));
  const last = getLastRegenTime(pKey);
  const today = new Date().toISOString().slice(0, 10);
  if (!last || last.toISOString().slice(0, 10) < today) {
    triggerRegen(s, draw);
  }
}

function loadOmdbSearch(s: State, draw: () => void) {
  if (!s.prompt) return;

  const simMatch = s.prompt.match(/^\/sim\s+(.+)/i);
  if (simMatch) {
    loadSimilarSearch(simMatch[1].trim(), s, draw);
    return;
  }

  s.tropeSearchLoading = true;
  s.status = `Searching "${s.prompt}"...`;
  draw();
  omdb.searchOmdb(s.prompt).then(results => {
    s.tropeSearchResults = results;
    s.tropeSearchCursor = 0;
    s.tropeInfo = null;
    s.status = results.length ? `${results.length} results` : "No results";
    if (results.length) {
      loadSearchItemInfo(s, draw);
      prefetchSearchInfo(results, draw);
    }
  }).catch((e) => { s.status = `Search failed: ${e?.message ?? e}`; })
    .finally(() => { s.tropeSearchLoading = false; draw(); });
}

async function loadSimilarSearch(query: string, s: State, draw: () => void) {
  s.tropeSearchLoading = true;
  s.status = `Finding titles similar to "${query}"...`;
  draw();
  try {
    // find the source title
    const matches = await omdb.searchOmdb(query);
    if (!matches[0]) {
      s.status = `No match for "${query}"`;
      s.tropeSearchLoading = false;
      draw();
      return;
    }
    // look up on TMDB and get similar
    const found = await tmdb.findByImdbId(matches[0].imdbID);
    if (!found) {
      s.status = "Not found on TMDB";
      s.tropeSearchLoading = false;
      draw();
      return;
    }
    const similar = await tmdb.getSimilar(found.tmdbId, found.type);
    // resolve each similar title to OMDb SearchResult format
    const results: omdb.SearchResult[] = [];
    for (const sim of similar) {
      const r = await omdb.searchOmdb(sim.title, sim.type, sim.year);
      if (r[0]) results.push(r[0]);
      if (results.length >= 10) break;
    }
    s.tropeSearchResults = results;
    s.tropeSearchCursor = 0;
    s.tropeInfo = null;
    s.status = `${results.length} similar to "${matches[0].Title}"`;
    if (results.length) {
      loadSearchItemInfo(s, draw);
      prefetchSearchInfo(results, draw);
    }
  } catch {
    s.status = "Similar search failed";
  } finally {
    s.tropeSearchLoading = false;
    draw();
  }
}

function prefetchSearchInfo(results: omdb.SearchResult[], draw: () => void) {
  for (const r of results) {
    if (!getItemInfo(r.imdbID)) {
      omdb.getById(r.imdbID).then(item => {
        if (item) {
          saveItem(item);
          draw();
        }
      }).catch(() => {});
    }
  }
}

function fetchInfo(imdbId: string, cb: (item: omdb.OmdbItem | null) => void, draw: () => void) {
  omdb.getById(imdbId).then(item => { cb(item); draw(); }).catch(() => {});
}

function loadStreaming(imdbId: string, s: State, draw: () => void) {
  if (s.streamingCache.has(imdbId)) return;
  tmdb.getProviders(imdbId).then(info => {
    s.streamingCache.set(imdbId, info);
    draw();
  }).catch(() => {
    s.streamingCache.set(imdbId, { providers: [], link: null });
  });
}

function loadSearch(s: State, draw: () => void) {
  if (!s.prompt) return;
  s.searchLoading = true;
  s.status = `Searching "${s.prompt}"...`;
  draw();

  searchLib.search(s.prompt)
    .then(results => {
      s.searchResults = results;
      s.searchCursor = 0;
      s.searchBest = bestResultIndex(results);
      s.searchCursor = s.searchBest;
      s.status = `${results.length} results`;
    })
    .catch(() => { s.status = "Search failed"; })
    .finally(() => { s.searchLoading = false; draw(); });
}

async function refreshTorrents(s: State) {
  try {
    s.torrents = await transmission.list();
    if (s.dlCursor >= s.torrents.length) s.dlCursor = Math.max(0, s.torrents.length - 1);
    if (s.pane === "right" && s.torrents[s.dlCursor]) {
      s.dlDetail = await transmission.getDetail(s.torrents[s.dlCursor].id);
    }
  } catch {}
}

async function doCleanup(s: State) {
  const threshold = config().cleanupRatio ?? 1.2;
  const removable = s.torrents.filter(t =>
    t.percentDone >= 1 && t.uploadRatio >= threshold
  );
  if (removable.length > 0) {
    await transmission.remove(removable.map(t => t.id));
    s.status = `Cleaned ${removable.length} torrent${removable.length > 1 ? "s" : ""}`;
  } else {
    s.status = "Nothing to clean";
  }
}

// rendering

const TABS = [
  { key: "l", label: "lists" },
  { key: "e", label: "explore" },
  { key: "s", label: "search" },
  { key: "d", label: "downloads" },
];

function fmtSize(bytes: number): string {
  if (bytes >= 1e9) return (bytes / 1e9).toFixed(1) + " GB";
  if (bytes >= 1e6) return (bytes / 1e6).toFixed(0) + " MB";
  return (bytes / 1e3).toFixed(0) + " KB";
}

function infoLines(item: omdb.OmdbItem | null, width: number, s?: State): string[] {
  if (!item) return [pc.dim("No info")];
  const lines: string[] = [];

  // title + ratings on same line(s), ratings right-aligned
  const ratingParts: string[] = [];
  const extRatings = item.Ratings as { Source: string; Value: string }[] | undefined;
  if (item.imdbRating && item.imdbRating !== "N/A") {
    ratingParts.push(pc.dim("IMDb ") + pc.yellow(item.imdbRating));
  }
  if (extRatings) {
    const rt = extRatings.find(r => r.Source === "Rotten Tomatoes");
    if (rt) {
      const pct = parseInt(rt.Value);
      ratingParts.push(pc.dim("RT ") + (pct >= 60 ? pc.green : pc.red)(rt.Value));
    }
    const mc = extRatings.find(r => r.Source === "Metacritic");
    if (mc) ratingParts.push(pc.dim("MC ") + pc.cyan(mc.Value));
  }
  const ids = s ? activeIds(s) : undefined;
  const userRatings = getRatingForImdb(item.imdbID, ids);
  if (userRatings.length) {
    if (s && isGroup(s)) {
      for (const r of userRatings) {
        ratingParts.push(pc.dim(profileName(s, r.profile_id) + " ") + pc.yellow(stars(r.rating)));
      }
    } else if (userRatings[0]) {
      ratingParts.push(pc.yellow(stars(userRatings[0].rating)));
    }
  }

  const titleStr = pc.bold(truncate(item.Title, width - 8)) + ` (${item.Year ?? "?"})`;
  const metaStr = `${item.Type ?? "?"}  \u2022  ${item.Runtime ?? "?"}`;
  // row 0: title + first rating, row 1: meta + second rating, then remaining ratings
  const leftCol = [titleStr, metaStr];
  for (let i = 0; i < Math.max(leftCol.length, ratingParts.length); i++) {
    const left = leftCol[i] ?? "";
    const right = ratingParts[i] ?? "";
    if (!right) {
      lines.push(left);
    } else {
      const leftVis = visWidth(left);
      const rightVis = visWidth(right);
      const maxLeft = width - rightVis - 1;
      if (leftVis > maxLeft && maxLeft > 0) {
        lines.push(`${truncVis(left, maxLeft)} ${right}`);
      } else {
        const gap = Math.max(1, width - leftVis - rightVis);
        lines.push(`${left}${" ".repeat(gap)}${right}`);
      }
    }
  }
  lines.push("");

  // genres centered
  if (item.Genre) {
    const genreStr = truncate(item.Genre, width);
    const genreVis = visWidth(genreStr);
    const gPad = Math.max(0, Math.floor((width - genreVis) / 2));
    lines.push(`${" ".repeat(gPad)}${pc.dim(genreStr)}`);
    lines.push("");
  }

  // credits
  if (item.Director && item.Director !== "N/A") lines.push(pc.dim("Dir: ") + truncate(item.Director, width - 6));
  const writer = item.Writer as string | undefined;
  if (writer && writer !== "N/A") lines.push(pc.dim("Writer: ") + truncate(writer, width - 9));
  if (item.Actors) lines.push(pc.dim("Cast: ") + truncate(item.Actors, width - 6));
  lines.push("");
  lines.push("");

  // description
  if (item.Plot && item.Plot !== "N/A") {
    lines.push(...wordWrap(item.Plot, width));
  }
  lines.push("");
  lines.push("");

  // streaming
  const watchInfo = s?.streamingCache.get(item.imdbID);
  if (watchInfo?.providers.length) {
    const labels: Record<string, string> = { stream: "Stream on", rent: "Rent on", buy: "Buy on" };
    for (let i = 0; i < watchInfo.providers.length && i < 12; i++) {
      const p = watchInfo.providers[i];
      const fk = pc.dim(`F${i + 1}`);
      lines.push(`${fk} ${pc.dim(labels[p.type])} ${p.name}`);
    }
    lines.push("");
  }

  // awards / accolades
  const awards = item.Awards as string | undefined;
  if (awards && awards !== "N/A") {
    lines.push(pc.bold("Awards"));
    lines.push(...wordWrap(awards, width));
  }

  return lines;
}

function torrentInfoLines(r: searchLib.Result | null, best: boolean, width: number): string[] {
  if (!r) return [pc.dim("No selection")];
  const lines: string[] = [];
  lines.push(...wordWrap(r.title, width));
  lines.push("");
  lines.push(pc.dim("Seeds: ") + pc.green(String(r.seeds)));
  lines.push(pc.dim("Peers: ") + pc.cyan(String(r.peers)));
  lines.push(pc.dim("Size: ") + pc.magenta(r.size));
  if (best) {
    lines.push("");
    lines.push(pc.green("\u2605 Best match"));
  }
  return lines;
}

function dlInfoLines(d: transmission.TorrentDetail | null, width: number, fileCursor = -1): string[] {
  if (!d) return [pc.dim("No selection")];
  const lines: string[] = [];
  const pct = Math.round(d.percentDone * 100) + "%";
  const pctVis = pct.length;
  const pctStr = d.percentDone >= 1 ? pc.green(pct) : pc.yellow(pct);
  const maxTitle = width - pctVis - 1;
  const titleStr = pc.bold(truncate(d.name, maxTitle));
  const titleVis = visWidth(titleStr);
  const pctPad = Math.max(1, width - titleVis - pctVis);
  lines.push(`${titleStr}${" ".repeat(pctPad)}${pctStr}`);

  const status = transmission.STATUS[d.status] ?? "Unknown";
  const sizeStr = pc.dim(fmtSize(d.totalSize));
  const statusStr = pc.cyan(status);
  const ratioStr = pc.dim("ratio ") + pc.yellow(d.uploadRatio >= 0 ? d.uploadRatio.toFixed(2) : "-.--");
  const sizeVis = visWidth(sizeStr);
  const statusVis = visWidth(statusStr);
  const ratioVis = visWidth(ratioStr);
  const r2space = width - sizeVis - statusVis - ratioVis;
  const r2left = Math.max(1, Math.floor(r2space / 2));
  const r2right = Math.max(1, r2space - r2left);
  lines.push(`${sizeStr}${" ".repeat(r2left)}${statusStr}${" ".repeat(r2right)}${ratioStr}`);

  const dlFmt = d.rateDownload > 0 ? pc.cyan : pc.dim;
  const ulFmt = d.rateUpload > 0 ? pc.green : pc.dim;
  const speedStr = dlFmt("\u2193" + fmtSpeed(d.rateDownload)) + "  " + ulFmt("\u2191" + fmtSpeed(d.rateUpload));
  const etaStr = d.eta > 0 ? "  " + pc.dim("ETA ") + fmtEta(d.eta) : "";
  const fullSpeed = speedStr + etaStr;
  const speedVis = visWidth(fullSpeed);
  const speedPad = Math.max(0, Math.floor((width - speedVis) / 2));
  lines.push(" ".repeat(speedPad) + fullSpeed);
  lines.push("");
  for (let i = 0; i < d.files.length; i++) {
    const f = d.files[i];
    const stat = d.fileStats[i];
    const name = f.name.split("/").pop() ?? f.name;
    const prioColor = !stat.wanted ? pc.dim("OFF") :
      stat.priority === 1 ? pc.green("HIGH") :
      stat.priority === -1 ? pc.yellow("LOW") : pc.dim("NORM");
    const prefix = i === fileCursor ? pc.yellow("\u25B6 ") : "  ";
    const prefixW = 2;
    const pct = f.length > 0 ? Math.round(f.bytesCompleted / f.length * 100) : 0;
    const meta = ` ${fmtSize(f.length).padStart(8)} [${prioColor}] ${pc.dim(pct + "%")}`;
    const metaW = visWidth(meta);
    const nameW = width - prefixW - metaW;
    const nameStr = padTo(truncate(name, nameW), nameW);
    lines.push(`${prefix}${nameStr}${meta}`);
  }
  return lines;
}

function buildToolbar(s: State): string[] {
  const cols = (process.stdout.columns ?? 100) - 1;
  const toolbar: string[] = [];

  // genre/profile bar
  if (s.profileMode) {
    const profStr = profileBar(s);
    const profVis = visWidth(profStr);
    const profPad = Math.max(0, cols - profVis - 1);
    toolbar.push(`${" ".repeat(profPad)}${profStr}`);
  } else if (s.genreMode) {
    const sep = pc.dim(" \u2022 ");
    const sepVis = 3;
    const items: { str: string; vis: number; start: number }[] = [];
    let pos = 0;
    for (let i = 0; i < s.genres.length; i++) {
      if (i > 0) pos += sepVis;
      const g = s.genres[i];
      const on = s.genrePending.has(g);
      const label = on ? pc.green(g) : pc.dim(g);
      const styled = i === s.genreCursor ? pc.underline(label) : label;
      items.push({ str: styled, vis: g.length, start: pos });
      pos += g.length;
    }
    const totalVis = pos;
    const curItem = items[s.genreCursor];
    const viewW = cols - 2;
    if (curItem) {
      if (curItem.start < s.genreScroll) {
        s.genreScroll = Math.max(0, curItem.start - 2);
      } else if (curItem.start + curItem.vis > s.genreScroll + viewW) {
        s.genreScroll = curItem.start + curItem.vis - viewW + 2;
      }
    }
    s.genreScroll = Math.max(0, Math.min(s.genreScroll, totalVis - viewW));
    const leftChev = s.genreScroll > 0 ? pc.dim("\u2039") : " ";
    const rightChev = s.genreScroll + viewW < totalVis ? pc.dim("\u203A") : " ";
    let row = "";
    let rendered = 0;
    for (let i = 0; i < s.genres.length; i++) {
      const item = items[i];
      const itemEnd = item.start + item.vis;
      if (itemEnd <= s.genreScroll) continue;
      if (item.start >= s.genreScroll + viewW) break;
      if (rendered > 0) row += sep;
      row += item.str;
      rendered++;
    }
    const rowVis = visWidth(row);
    const truncated = rowVis > viewW ? truncVis(row, viewW) : row;
    toolbar.push(`${leftChev}${truncated}${rightChev}`);
  } else {
    let genreStr: string;
    if (s.genreSelected.size) {
      const parts = s.genres
        .filter(g => s.genreSelected.has(g))
        .map(g => pc.green(g));
      genreStr = parts.join(pc.dim(" \u2022 "));
    } else {
      genreStr = pc.dim(pc.italic("all"));
    }
    const activeProfile = isGroup(s)
      ? pc.magenta(s.activeProfiles.map(p => p.name).join(" + "))
      : pc.dim(s.activeProfiles[0]?.name ?? "");
    const activeVis = visWidth(activeProfile);
    const gVis2 = visWidth(genreStr);
    const gap = Math.max(2, cols - gVis2 - activeVis - 1);
    toolbar.push(`${genreStr}${" ".repeat(gap)}${activeProfile}`);
  }

  // prompt (torrent search only — search tab puts it in panel content)
  if (s.promptActive && s.tab !== "explore" && s.tab !== "search") {
    toolbar.push(`  ${pc.cyan("/")} ${s.prompt}\u2588`);
    toolbar.push("");
  }

  return toolbar;
}

function renderPanels(s: State): { left: string[]; right: string[] } {
  const [leftW, rightW] = columnWidths([55, 45]);

  const left: string[] = [];
  let right: string[] = [];

  switch (s.tab) {
    case "explore": {
      if (s.tropeView === "items") {
        // items within a trope
        const trope = s.tropes[s.tropeCursor];
        if (trope) {
          left.push(`  ${trope.emoji ? trope.emoji + " " : ""}${pc.bold(trope.name)}`);
          left.push("");
          for (const line of wordWrap(trope.description, leftW - 2)) {
            left.push(`  ${pc.dim(line)}`);
          }
          left.push("");
        }
        if (!s.tropeItems.length) {
          left.push(pc.dim("  No items"));
        } else {
          for (let i = 0; i < s.tropeItems.length; i++) {
            const it = s.tropeItems[i];
            const prefix = i === s.tropeItemCursor ? pc.yellow("\u25B6 ") : "  ";
            const yearStr = pc.dim(it.year ?? "?");
            const yearVis = it.year?.length ?? 1;
            const genreRaw = it.genre ?? "";
            const maxGenre = Math.floor(leftW * 0.4);
            const genreTrunc = truncate(genreRaw, maxGenre);
            const genreStr = genreTrunc ? pc.dim(genreTrunc) : "";
            const genreVis = visWidth(genreStr);
            const titleW = Math.max(8, leftW - yearVis - genreVis - 5);
            const titleStr = truncate(it.title, titleW);
            const usedW = 2 + visWidth(titleStr) + 1 + yearVis;
            const genreGap = Math.max(1, leftW - usedW - genreVis);
            left.push(`${prefix}${titleStr} ${yearStr}${" ".repeat(genreGap)}${genreStr}`);
            const info = getItemInfo(it.imdb_id);
            if (info?.Plot && info.Plot !== "N/A") {
              const plotLines = wordWrap(info.Plot, leftW - 4);
              for (let j = 0; j < Math.min(plotLines.length, 3); j++) {
                left.push(`    ${pc.dim(plotLines[j])}`);
              }
            }
            if (i < s.tropeItems.length - 1) left.push("");
          }
        }
        right = infoLines(s.tropeInfo, rightW, s);
      } else {
        // trope list
        if (s.regenStatus) {
          left.push(`  ${pc.dim(s.regenStatus)}`);
          left.push("");
        }
        if (!s.tropes.length && !s.regenLoading) {
          left.push(pc.dim("  No tropes yet. Press r to generate."));
        } else {
          for (let i = 0; i < s.tropes.length; i++) {
            const t = s.tropes[i];
            const prefix = i === s.tropeCursor ? pc.yellow("\u25B6 ") : "  ";
            left.push(`${prefix}${t.emoji ? t.emoji + " " : ""}${pc.bold(t.name)} ${pc.dim(`(${t.item_count ?? 0})`)}`);
            const descW = leftW - 4;
            const descText = t.description.length > descW * 3
              ? t.description.slice(0, descW * 3 - 1) + "\u2026"
              : t.description;
            const descLines = wordWrap(descText, descW);
            for (let j = 0; j < Math.min(descLines.length, 3); j++) {
              left.push(`    ${pc.dim(descLines[j])}`);
            }
            if (i < s.tropes.length - 1) left.push("");
          }
          if (s.tropePreview.length) {
            const trope = s.tropes[s.tropeCursor];
            if (trope) {
              right.push(`${trope.emoji ? trope.emoji + " " : ""}${pc.bold(trope.name)}`);
              right.push("");
              right.push(...wordWrap(trope.description, rightW));
              right.push("");
            }
            for (let i = 0; i < s.tropePreview.length; i++) {
              const it = s.tropePreview[i];
              const yearStr = pc.dim(it.year ?? "?");
              const yearVis = it.year?.length ?? 1;
              const genreRaw = it.genre ?? "";
              const maxGenreR = Math.floor(rightW * 0.4);
              const genreTruncR = truncate(genreRaw, maxGenreR);
              const genreStr = genreTruncR ? pc.dim(genreTruncR) : "";
              const genreVis = visWidth(genreStr);
              const titleW = Math.max(8, rightW - yearVis - genreVis - 5);
              const titleStr = truncate(it.title, titleW);
              const usedW = 2 + visWidth(titleStr) + 1 + yearVis;
              const genreGap = Math.max(1, rightW - usedW - genreVis);
              right.push(`  ${titleStr} ${yearStr}${" ".repeat(genreGap)}${genreStr}`);
              const info = getItemInfo(it.imdb_id);
              if (info?.Plot && info.Plot !== "N/A") {
                const plotLines = wordWrap(info.Plot, rightW - 4);
                for (let j = 0; j < Math.min(plotLines.length, 3); j++) {
                  right.push(`    ${pc.dim(plotLines[j])}`);
                }
              }
              if (i < s.tropePreview.length - 1) right.push("");
            }
          } else {
            right = [];
          }
        }
      }
      break;
    }
    case "search": {
      // prompt bar
      const searchInput = s.promptActive
        ? `  ${pc.cyan("/")} ${s.prompt}\u2588`
        : s.prompt
          ? `  ${pc.cyan("/")} ${pc.dim(s.prompt)}`
          : `  ${pc.dim("Type to search OMDb...")}`;
      left.push(searchInput);
      left.push("");

      if (s.tropeSearchLoading) {
        left.push(pc.dim("  Searching..."));
      } else if (!s.tropeSearchResults.length) {
        if (s.prompt) {
          left.push(pc.dim("  No results"));
        }
      } else {
        for (let i = 0; i < s.tropeSearchResults.length; i++) {
          const r = s.tropeSearchResults[i];
          const prefix = i === s.tropeSearchCursor ? pc.yellow("\u25B6 ") : "  ";
          const info = getItemInfo(r.imdbID);
          if (info) {
            const yearStr = pc.dim(info.Year ?? r.Year);
            const yearVis = (info.Year ?? r.Year).length;
            const genreRaw = info.Genre ?? "";
            const maxGenre = Math.floor(leftW * 0.4);
            const genreTrunc = truncate(genreRaw, maxGenre);
            const genreStr = genreTrunc ? pc.dim(genreTrunc) : "";
            const genreVis = visWidth(genreStr);
            const titleW = Math.max(8, leftW - yearVis - genreVis - 5);
            const titleStr = truncate(r.Title, titleW);
            const usedW = 2 + visWidth(titleStr) + 1 + yearVis;
            const genreGap = Math.max(1, leftW - usedW - genreVis);
            left.push(`${prefix}${titleStr} ${yearStr}${" ".repeat(genreGap)}${genreStr}`);
            if (info.Plot && info.Plot !== "N/A") {
              const plotLines = wordWrap(info.Plot, leftW - 4);
              for (let j = 0; j < Math.min(plotLines.length, 3); j++) {
                left.push(`    ${pc.dim(plotLines[j])}`);
              }
            }
          } else {
            left.push(`${prefix}${pc.bold(r.Title)} ${pc.dim(`(${r.Year})  ${r.Type}`)}`);
          }
          if (i < s.tropeSearchResults.length - 1) left.push("");
        }
      }
      right = infoLines(s.tropeInfo, rightW, s);
      break;
    }
    case "torrent": {
      if (s.torrentSearch) {
        if (s.searchLoading) {
          left.push(pc.dim("  Searching..."));
        } else if (!s.searchResults.length) {
          left.push(pc.dim("  No results"));
        } else {
          for (let i = 0; i < s.searchResults.length; i++) {
            const r = s.searchResults[i];
            const isBest = i === s.searchBest;
            const prefix = i === s.searchCursor ? pc.yellow("\u25B6 ") : (isBest ? pc.green("\u2605 ") : "  ");
            left.push(`${prefix}${pc.green(String(r.seeds).padStart(5))} ${pc.magenta(r.size.padEnd(8))} ${truncate(r.title, leftW - 18)}`);
          }
        }
        const sr = s.searchResults[s.searchCursor];
        right = torrentInfoLines(sr ?? null, s.searchCursor === s.searchBest, rightW);
      } else {
        if (!s.torrents.length) {
          left.push(pc.dim("  No active downloads"));
        } else {
          for (let i = 0; i < s.torrents.length; i++) {
            const t = s.torrents[i];
            const prefix = i === s.dlCursor ? pc.yellow(s.pane === "right" ? "\u25CB " : "\u25B6 ") : "  ";
            const status = transmission.STATUS[t.status] ?? "?";
            const bar = progressBar(t.percentDone, 10);
            const barVis = visWidth(bar);
            left.push(`${prefix}${truncate(t.name, leftW - 4)}`);
            const dlC = t.rateDownload > 0 ? pc.cyan : pc.dim;
            const ulC = t.rateUpload > 0 ? pc.green : pc.dim;
            const meta = `    ${pc.dim(status)}  ${dlC("\u2193" + fmtSpeed(t.rateDownload))}  ${ulC("\u2191" + fmtSpeed(t.rateUpload))}`;
            const metaVis = visWidth(meta);
            const gap = Math.max(1, leftW - metaVis - barVis - 2);
            left.push(`${meta}${" ".repeat(gap)}${bar}`);
            if (i < s.torrents.length - 1) left.push("");
          }
        }
        const t = s.torrents[s.dlCursor];
        if (t && s.dlDetail) {
          right = dlInfoLines(s.dlDetail, rightW, s.pane === "right" ? s.dlFileCursor : -1);
        } else {
          right = [pc.dim("Select a torrent")];
        }
      }
      break;
    }
    case "lists": {
      const items = buildList(s);
      if (!items.length) {
        left.push(pc.dim("  Empty"));
      } else {
        const group = isGroup(s);
        const emptyStars = pc.dim("\u2606\u2606\u2606\u2606\u2606");
        let prevWl: boolean | null = null;
        for (let i = 0; i < items.length; i++) {
          const it = items[i];
          if (prevWl === null && it.onWatchlist) {
            left.push(pc.bold("  Watchlist"));
            left.push("");
          } else if ((prevWl === true || prevWl === null) && !it.onWatchlist) {
            if (prevWl === true) left.push("");
            left.push(pc.bold("  History"));
            left.push("");
          }
          prevWl = it.onWatchlist;
          const prefix = i === s.listCursor ? pc.yellow("\u25B6 ") : "  ";
          const ratingStr = it.rating != null
            ? (group ? pc.magenta(stars(it.rating)) : pc.yellow(stars(it.rating)))
            : emptyStars;
          const yearStr = pc.dim(it.year ?? "?");
          const yearVis = it.year?.length ?? 1;
          const genreRaw = it.genre ?? "";
          const maxGenreL = Math.floor(leftW * 0.35);
          const genreTruncL = truncate(genreRaw, maxGenreL);
          const genreStr = genreTruncL ? pc.dim(genreTruncL) : "";
          const genreVis = visWidth(genreStr);
          const titleW = Math.max(8, leftW - 8 - yearVis - genreVis - 4);
          const titleStr = truncate(it.title, titleW);
          const usedW = 2 + 6 + visWidth(titleStr) + 1 + yearVis; // prefix + rating + title + spaces
          const genreGap = Math.max(1, leftW - usedW - genreVis);
          left.push(`${prefix}${ratingStr} ${titleStr} ${yearStr}${" ".repeat(genreGap)}${genreStr}`);
        }
      }
      right = infoLines(s.listInfo, rightW, s);
      break;
    }
  }

  s.rightLineCount = right.length;
  return { left, right };
}

// key handling

function profileBar(s: State): string {
  const parts = s.profiles.map((p, i) => {
    const on = s.profilePending.has(p.id);
    const label = on ? pc.green(p.name) : pc.dim(p.name);
    return i === s.profileCursor ? pc.underline(label) : label;
  });
  return parts.join(pc.dim(" \u2022 ")) + pc.dim(" \u2022 ") + pc.cyan("+ new");
}

function getTabKeys(s: State): Keys {
  if (s.profileMode) {
    return [["left", ""], ["right", ""], [" ", "toggle"], ["+", "new"], ["enter", "confirm"], ["esc", "cancel"]];
  }
  if (s.genreMode) {
    return [["left", ""], ["right", ""], [" ", "toggle"], ["enter", "confirm"], ["esc", "clear"]];
  }

  const arrows: Keys = [["up", ""], ["down", ""]];

  switch (s.tab) {
    case "explore": {
      if (s.tropeView === "items") {
        return [...arrows, ["0-5", "rate"], ["w", "watchlist"], ["f", "fetch"], ["t", "trailer"]];
      }
      return [...arrows, ["r", "regen"], ["x", "delete"]];
    }
    case "search": {
      return [...arrows, ["/", "search"], ["0-5", "rate"], ["w", "watchlist"], ["f", "fetch"], ["t", "trailer"]];
    }
    case "torrent":
      if (s.pane === "right") {
        return [...arrows, ["3", "high"], ["2", "med"], ["1", "low"], ["0", "off"], ["w", "watch"]];
      }
      if (s.torrentSearch) {
        return [...arrows, ["/", "query"], ["enter", "add"]];
      }
      return [...arrows, ["/", "search"], ["x", "remove"], ["c", "cleanup"]];
    case "lists":
      if (s.pane === "right") {
        return [...arrows, ["f", "fetch"], ["t", "trailer"]];
      }
      const items = buildList(s);
      const cur = items[s.listCursor];
      const wlKey: Keys = cur?.onWatchlist ? [["u", "unwatchlist"]] : [["w", "watchlist"]];
      return [...arrows, ["0-5", "rate"], ["f", "fetch"], ["t", "trailer"], ...wlKey];
    default: return [...arrows];
  }
}

async function handleKey(key: string, s: State, draw: () => void): Promise<"quit" | void> {
  // genre mode
  if (s.genreMode) {
    if (key === "left" && s.genreCursor > 0) {
      s.genreCursor--;
    } else if (key === "right" && s.genreCursor < s.genres.length - 1) {
      s.genreCursor++;
    } else if (key === " " && s.genres[s.genreCursor]) {
      const g = s.genres[s.genreCursor];
      if (s.genrePending.has(g)) {
        s.genrePending.delete(g);
      } else {
        s.genrePending.add(g);
      }
    } else if (key === "enter") {
      s.genreSelected = new Set(s.genrePending);
      s.genreMode = false;
      s.listCursor = 0; s.listInfo = null;
      loadTropes(s);
    } else if (key === "esc") {
      s.genreSelected.clear();
      s.genrePending.clear();
      s.genreMode = false;
      s.listCursor = 0; s.listInfo = null;
      loadTropes(s);
    }
    return;
  }

  // profile mode
  if (s.profileMode) {
    if (key === "esc") {
      s.profileMode = false;
    } else if (key === "left" && s.profileCursor > 0) {
      s.profileCursor--;
    } else if (key === "right" && s.profileCursor < s.profiles.length - 1) {
      s.profileCursor++;
    } else if (key === " " && s.profiles[s.profileCursor]) {
      const id = s.profiles[s.profileCursor].id;
      if (s.profilePending.has(id)) {
        s.profilePending.delete(id);
      } else {
        s.profilePending.add(id);
      }
    } else if (key === "+" || (key === "right" && s.profileCursor >= s.profiles.length - 1)) {
      // create new profile
      s.profileMode = false;
      draw();
      const name = await input({ message: "Profile name:" });
      if (name?.trim()) {
        const created = createProfile(name.trim());
        s.profiles = getProfiles();
        s.profilePending.add(created.id);
      }
      s.profileMode = true;
      s.profileCursor = s.profiles.length - 1;
    } else if (key === "enter") {
      if (s.profilePending.size > 0) {
        s.activeProfiles = s.profiles.filter(p => s.profilePending.has(p.id));
        setActiveProfileIds(s.activeProfiles.map(p => p.id));
      }
      s.profileMode = false;
      s.genres = allGenres(activeIds(s));
      s.genreSelected.clear();
      s.genrePending.clear();
      s.listCursor = 0; s.listInfo = null;
      loadTropes(s);
      s.status = `Profiles: ${s.activeProfiles.map(p => p.name).join(", ")}`;
    }
    return;
  }

  // prompt mode
  if (s.promptActive) {
    if (key === "esc") {
      s.promptActive = false;
      if (s.tab === "search" && !s.tropeSearchResults.length) {
        s.prompt = "";
      }
      if (s.tab === "torrent" && !s.searchResults.length) {
        s.torrentSearch = false;
      }
    } else if (key === "down" && s.tab === "search" && s.tropeSearchResults.length) {
      s.promptActive = false;
      s.tropeSearchCursor = 0;
      loadSearchItemInfo(s, draw);
    } else if (key === "enter") {
      if (debounceTimer) clearTimeout(debounceTimer);
      s.promptActive = false;
      if (s.tab === "search" && s.prompt) loadOmdbSearch(s, draw);
      else if (s.tab === "torrent") loadSearch(s, draw);
    } else if (key === "backspace") {
      s.prompt = s.prompt.slice(0, -1);
      if (debounceTimer) clearTimeout(debounceTimer);
      if (s.tab === "search" && !s.prompt) {
        s.tropeSearchResults = [];
        s.tropeInfo = null;
      } else if (s.tab === "search" && s.prompt) {
        debounceTimer = setTimeout(() => loadOmdbSearch(s, draw), 500);
      } else if (s.tab === "torrent" && s.prompt) {
        debounceTimer = setTimeout(() => loadSearch(s, draw), 500);
      }
    } else if (key.length === 1 && key >= " ") {
      s.prompt += key;
      if (debounceTimer) clearTimeout(debounceTimer);
      if (s.tab === "search") {
        debounceTimer = setTimeout(() => loadOmdbSearch(s, draw), 500);
      } else if (s.tab === "torrent") {
        debounceTimer = setTimeout(() => loadSearch(s, draw), 500);
      }
    }
    return;
  }

  // standard keys (quit + tab switching)
  const canSwitch = !s.genreMode && !s.profileMode && !s.promptActive;
  const stdResult = handleStdKey(
    key, TAB_ORDER.length, TAB_ORDER.indexOf(s.tab),
    { l: 0, e: 1, s: 2, d: 3 }, canSwitch,
  );
  if (stdResult) {
    if (stdResult.action === "quit") return "quit";
    const newTab = TAB_ORDER[stdResult.index];
    if (newTab !== s.tab) {
      s.tab = newTab;
      s.status = "";
      s.pane = "left";
      s.leftScroll = mkScroll(); s.rightScroll = mkScroll();
      if (newTab === "lists") loadListInfo(s, draw);
      if (newTab === "search") {
        s.promptActive = true;
        s.prompt = "";
      }
      if (newTab === "torrent" && !s.dlDetail && s.torrents.length) loadDlDetail(s).then(draw);
    }
    return;
  }

  // genre selector
  if (key === "g") {
    s.genreMode = true;
    s.genreCursor = 0;
    s.genreScroll = 0;
    s.genrePending = new Set(s.genreSelected);
    return;
  }

  // profile switcher
  if (key === "p") {
    s.profileMode = true;
    s.profileCursor = 0;
    s.profilePending = new Set(activeIds(s));
    return;
  }

  // prompt activation
  if (key === "/" && (s.tab === "search" || s.tab === "torrent")) {
    s.promptActive = true;
    s.prompt = "";
    if (s.tab === "search") {
      s.tropeSearchResults = [];
      s.tropeSearchCursor = 0;
      s.tropeInfo = null;
    }
    if (s.tab === "torrent") {
      s.torrentSearch = true;
    }
    return;
  }

  // backspace = back
  if (key === "backspace") {
    if (s.tab === "explore" && s.tropeView === "items") {
      s.tropeView = "tropes";
      s.tropeInfo = null;
    } else if (s.tab === "search" && s.tropeSearchResults.length) {
      s.tropeSearchResults = [];
      s.tropeInfo = null;
      s.prompt = "";
    } else if (s.tab === "lists" && s.pane === "right") {
      s.pane = "left";
    } else if (s.tab === "torrent" && s.pane === "right") {
      s.pane = "left";
      s.dlDetail = null;
    } else if (s.tab === "torrent" && s.torrentSearch) {
      s.torrentSearch = false;
      s.searchResults = [];
      s.status = "";
    } else if (s.tab === "torrent") {
      // fall through to handleDownload for torrent removal
    } else {
      return;
    }
  }

  // tab-specific keys
  switch (s.tab) {
    case "explore": return handleTropes(key, s, draw);
    case "search": return handleSearchTab(key, s, draw);
    case "torrent": return s.torrentSearch ? handleSearch(key, s, draw) : handleDownload(key, s, draw);
    case "lists": return handleLists(key, s, draw);
  }
}

function handleTropes(key: string, s: State, draw: () => void) {
  if (s.tropeView === "items") {
    return handleTropeItems(key, s, draw);
  }

  // trope list navigation
  const leftNav = { kind: "cursor" as const, pos: s.tropeCursor, count: s.tropes.length, drill: true };
  const navPanels = [
    { scroll: s.leftScroll, nav: leftNav },
    { scroll: s.rightScroll, nav: { kind: "scroll" as const, count: s.rightLineCount } },
  ];
  const focusIdx = s.pane === "left" ? 0 : 1;
  const act = columnsNav(key, navPanels, focusIdx);
  if (act) {
    if (act.type === "select") {
      if (s.tropes[s.tropeCursor]) {
        s.tropeItems = s.tropePreview.length ? [...s.tropePreview] : tropeItemList(s.tropes[s.tropeCursor].id, s);
        s.tropeItemCursor = 0;
        s.tropeView = "items";
        s.tropeInfo = null;
        loadTropeItemInfo(s, draw);
      }
    } else if (act.type === "cursor") {
      s.tropeCursor = leftNav.pos;
      loadTropePreview(s);
    }
    // "back" on trope list = no-op (already at top level)
    return;
  }

  // trope list action keys
  if (key === "r") {
    triggerRegen(s, draw);
  } else if (key === "x" && s.tropes[s.tropeCursor]) {
    const trope = s.tropes[s.tropeCursor];
    deleteTrope(trope.id);
    loadTropes(s);
    s.status = `Deleted "${trope.name}"`;
  }
}

function handleSearchTab(key: string, s: State, draw: () => void) {
  if (!s.tropeSearchResults.length) {
    // no results yet — typing activates prompt
    if (key.length === 1 && key >= " ") {
      s.promptActive = true;
      s.prompt = key;
      s.tropeSearchResults = [];
      s.tropeSearchCursor = 0;
      s.tropeInfo = null;
      if (debounceTimer) clearTimeout(debounceTimer);
      debounceTimer = setTimeout(() => loadOmdbSearch(s, draw), 500);
    }
    return;
  }

  // search results navigation
  return handleTropeSearch(key, s, draw);
}

function handleTropeItems(key: string, s: State, draw: () => void) {
  const leftNav = { kind: "cursor" as const, pos: s.tropeItemCursor, count: s.tropeItems.length };
  const navPanels = [
    { scroll: s.leftScroll, nav: leftNav },
    { scroll: s.rightScroll, nav: { kind: "scroll" as const, count: s.rightLineCount } },
  ];
  const focusIdx = s.pane === "left" ? 0 : 1;
  const act = columnsNav(key, navPanels, focusIdx);
  if (act) {
    if (act.type === "select") {
      s.pane = "right";
    } else if (act.type === "focus") {
      s.pane = act.index === 0 ? "left" : "right";
    } else if (act.type === "back") {
      s.tropeView = "tropes";
      s.tropeInfo = null;
    } else if (act.type === "cursor" && s.pane === "left") {
      s.tropeItemCursor = leftNav.pos;
      loadTropeItemInfo(s, draw);
    }
    return;
  }

  if (s.pane === "right") return;

  const it = s.tropeItems[s.tropeItemCursor];
  if (it) {
    handleItemAction(key, it, s, draw);
  }
}

function handleTropeSearch(key: string, s: State, draw: () => void) {
  const leftNav = { kind: "cursor" as const, pos: s.tropeSearchCursor, count: s.tropeSearchResults.length };
  const navPanels = [
    { scroll: s.leftScroll, nav: leftNav },
    { scroll: s.rightScroll, nav: { kind: "scroll" as const, count: s.rightLineCount } },
  ];
  const focusIdx = s.pane === "left" ? 0 : 1;
  const act = columnsNav(key, navPanels, focusIdx);
  if (act) {
    if (act.type === "focus") {
      s.pane = act.index === 0 ? "left" : "right";
    } else if (act.type === "none" && key === "up" && s.tropeSearchCursor === 0) {
      s.promptActive = true;
    } else if (act.type === "cursor" && s.pane === "left") {
      s.tropeSearchCursor = leftNav.pos;
      loadSearchItemInfo(s, draw);
    }
    return;
  }

  if (s.pane === "right") return;

  const r = s.tropeSearchResults[s.tropeSearchCursor];
  if (r) {
    handleSearchItemAction(key, r, s, draw);
  }
}

function handleItemAction(key: string, it: ListItem, s: State, draw: () => void) {
  if (key === "0") {
    omdb.getById(it.imdb_id).then(item => {
      if (item) {
        const id = saveItem(item);
        for (const pid of activeIds(s)) removeRating(id, pid);
        it.rating = null;
        s.status = `Unrated ${it.title}`;
        draw();
      }
    }).catch(() => {});
  } else if (key >= "1" && key <= "5") {
    const rating = parseInt(key);
    omdb.getById(it.imdb_id).then(item => {
      if (item) {
        const id = saveItem(item);
        for (const pid of activeIds(s)) upsertRating(id, rating, pid);
        it.rating = rating;
        s.status = `Rated ${it.title} ${stars(rating)}`;
        draw();
      }
    }).catch(() => {});
  } else if (key === "w") {
    omdb.getById(it.imdb_id).then(item => {
      if (item) {
        const id = saveItem(item);
        for (const pid of activeIds(s)) addToWatchlist(id, pid);
        s.status = `Added ${it.title} to watchlist`;
        draw();
      }
    }).catch(() => {});
  } else if (key === "f") {
    s.tab = "torrent";
    s.torrentSearch = true;
    s.prompt = it.title;
    loadSearch(s, draw);
  } else if (key === "t") {
    openTrailer(it.title, it.year ?? undefined);
  } else if (key.startsWith("f") && key.length <= 3) {
    const n = parseInt(key.slice(1));
    if (n >= 1 && n <= 12) openProvider(it.imdb_id, n - 1, it.title, s);
  }
}

function handleSearchItemAction(key: string, r: omdb.SearchResult, s: State, draw: () => void) {
  if (key === "0") {
    omdb.getById(r.imdbID).then(item => {
      if (item) {
        const id = saveItem(item);
        for (const pid of activeIds(s)) removeRating(id, pid);
        s.status = `Unrated ${r.Title}`;
        draw();
      }
    }).catch(() => {});
  } else if (key >= "1" && key <= "5") {
    const rating = parseInt(key);
    omdb.getById(r.imdbID).then(item => {
      if (item) {
        const id = saveItem(item);
        for (const pid of activeIds(s)) upsertRating(id, rating, pid);
        s.status = `Rated ${r.Title} ${stars(rating)}`;
        draw();
      }
    }).catch(() => {});
  } else if (key === "w") {
    omdb.getById(r.imdbID).then(item => {
      if (item) {
        const id = saveItem(item);
        for (const pid of activeIds(s)) addToWatchlist(id, pid);
        s.status = `Added ${r.Title} to watchlist`;
        draw();
      }
    }).catch(() => {});
  } else if (key === "f") {
    s.tab = "torrent";
    s.torrentSearch = true;
    s.prompt = r.Title;
    loadSearch(s, draw);
  } else if (key === "t") {
    openTrailer(r.Title, r.Year);
  } else if (key.startsWith("f") && key.length <= 3) {
    const n = parseInt(key.slice(1));
    if (n >= 1 && n <= 12) openProvider(r.imdbID, n - 1, r.Title, s);
  }
}

let infoSeq = 0;

function loadTropeItemInfo(s: State, draw: () => void) {
  const it = s.tropeItems[s.tropeItemCursor];
  if (!it) return;
  const cached = getItemInfo(it.imdb_id);
  if (cached) s.tropeInfo = cached;
  const seq = ++infoSeq;
  setTimeout(() => {
    if (seq !== infoSeq) return;
    loadStreaming(it.imdb_id, s, draw);
    if (!cached) {
      fetchInfo(it.imdb_id, item => { s.tropeInfo = item; }, draw);
    }
  }, 100);
}

function loadSearchItemInfo(s: State, draw: () => void) {
  const r = s.tropeSearchResults[s.tropeSearchCursor];
  if (!r) return;
  const cached = getItemInfo(r.imdbID);
  if (cached) s.tropeInfo = cached;
  const seq = ++infoSeq;
  setTimeout(() => {
    if (seq !== infoSeq) return;
    loadStreaming(r.imdbID, s, draw);
    if (!cached) {
      fetchInfo(r.imdbID, item => { s.tropeInfo = item; }, draw);
    }
  }, 100);
}

function handleLists(key: string, s: State, draw: () => void) {
  const items = buildList(s);

  const leftNav = { kind: "cursor" as const, pos: s.listCursor, count: items.length };
  const navPanels = [
    { scroll: s.leftScroll, nav: leftNav },
    { scroll: s.rightScroll, nav: { kind: "scroll" as const, count: s.rightLineCount } },
  ];
  const focusIdx = s.pane === "left" ? 0 : 1;
  const act = columnsNav(key, navPanels, focusIdx);
  if (act) {
    if (act.type === "focus") {
      if (act.index === 1 && !items[s.listCursor]) return;
      s.pane = act.index === 0 ? "left" : "right";
      if (act.index === 1) s.rightScroll = mkScroll();
    } else if (act.type === "cursor") {
      s.listCursor = leftNav.pos;
      const cur = items[s.listCursor];
      if (cur) loadListInfoFor(cur.imdb_id, s, draw);
    }
    return;
  }

  if (s.pane === "right") {
    const cur = items[s.listCursor];
    if (key === "f" && cur) {
      s.pane = "left";
      s.tab = "torrent";
      s.torrentSearch = true;
      s.prompt = cur.title;
      loadSearch(s, draw);
    } else if (key === "t" && cur) {
      openTrailer(cur.title, cur.year ?? undefined);
    } else if (key.startsWith("f") && key.length <= 3 && cur) {
      const n = parseInt(key.slice(1));
      if (n >= 1 && n <= 12) openProvider(cur.imdb_id, n - 1, cur.title, s);
    }
    return;
  }
  if (key === "f" && items[s.listCursor]) {
    s.tab = "torrent";
    s.torrentSearch = true;
    s.prompt = items[s.listCursor].title;
    loadSearch(s, draw);
  } else if (key === "t" && items[s.listCursor]) {
    openTrailer(items[s.listCursor].title, items[s.listCursor].year ?? undefined);
  } else if (key === "u" && items[s.listCursor]) {
    const it = items[s.listCursor];
    if (it.onWatchlist) {
      removeFromWatchlist(it.imdb_id, it.profile_id);
      s.status = `Removed ${it.title} from watchlist`;
      const remaining = buildList(s);
      if (s.listCursor >= remaining.length) s.listCursor = Math.max(0, remaining.length - 1);
      loadListInfo(s, draw);
    }
  } else if (key === "w" && items[s.listCursor]) {
    const it = items[s.listCursor];
    if (!it.onWatchlist) {
      omdb.getById(it.imdb_id).then(item => {
        if (item) {
          const id = saveItem(item);
          for (const pid of activeIds(s)) addToWatchlist(id, pid);
          s.status = `Added ${it.title} to watchlist`;
          draw();
        }
      }).catch(() => {});
    }
  } else if (key === "0" && items[s.listCursor]) {
    const it = items[s.listCursor];
    omdb.getById(it.imdb_id).then(item => {
      if (item) {
        const id = saveItem(item);
        for (const pid of activeIds(s)) removeRating(id, pid);
        s.status = `Unrated ${it.title}`;
        draw();
      }
    }).catch(() => {});
  } else if (key >= "1" && key <= "5" && items[s.listCursor]) {
    const it = items[s.listCursor];
    const rating = parseInt(key);
    omdb.getById(it.imdb_id).then(item => {
      if (item) {
        const id = saveItem(item);
        for (const pid of activeIds(s)) upsertRating(id, rating, pid);
        s.status = `Rated ${it.title} ${stars(rating)}`;
        draw();
      }
    }).catch(() => {});
  } else if (key.startsWith("f") && key.length <= 3 && items[s.listCursor]) {
    const n = parseInt(key.slice(1));
    const it = items[s.listCursor];
    if (n >= 1 && n <= 12) openProvider(it.imdb_id, n - 1, it.title, s);
  }
}

let listInfoSeq = 0;

function loadListInfo(s: State, draw: () => void) {
  const it = buildList(s)[s.listCursor];
  if (!it) return;
  loadListInfoFor(it.imdb_id, s, draw);
}

function loadListInfoFor(imdbId: string, s: State, draw: () => void) {
  const cached = getItemInfo(imdbId);
  if (cached) s.listInfo = cached;
  const seq = ++listInfoSeq;
  setTimeout(() => {
    if (seq !== listInfoSeq) return;
    loadStreaming(imdbId, s, draw);
    if (!cached) {
      fetchInfo(imdbId, item => { s.listInfo = item; }, draw);
    }
  }, 100);
}

async function handleSearch(key: string, s: State, draw: () => void) {
  if (key === "up" && s.searchCursor > 0) {
    s.searchCursor--;
  } else if (key === "down" && s.searchCursor < s.searchResults.length - 1) {
    s.searchCursor++;
  } else if ((key === "enter") && s.searchResults[s.searchCursor]) {
    const r = s.searchResults[s.searchCursor];
    s.status = `Adding ${truncate(r.title, 40)}...`;
    draw();
    try {
      await transmission.add(r.magnet);
      s.status = "Added to downloads";
      await refreshTorrents(s);
      s.torrentSearch = false;
      s.pane = "left";
      // try to focus the new torrent (usually last)
      s.dlCursor = Math.max(0, s.torrents.length - 1);

      // auto-select episodes if season pack
      const t = s.torrents[s.dlCursor];
      if (t) {
        const detail = await transmission.getDetail(t.id);
        if (detail && detail.files.length > 0) {
          await autoSelectEpisodes(t.id, detail.files);
          s.dlDetail = await transmission.getDetail(t.id);
        }
      }
    } catch {
      s.status = "Failed to add torrent";
    }
  }
}

async function handleDownload(key: string, s: State, draw: () => void) {
  const files = s.dlDetail?.files ?? [];
  const leftNav = { kind: "cursor" as const, pos: s.dlCursor, count: s.torrents.length };
  const rightNav = { kind: "cursor" as const, pos: s.dlFileCursor, count: files.length };
  const navPanels = [
    { scroll: s.leftScroll, nav: leftNav },
    { scroll: s.rightScroll, nav: rightNav },
  ];
  const focusIdx = s.pane === "left" ? 0 : 1;
  const act = columnsNav(key, navPanels, focusIdx);
  if (act) {
    if (act.type === "focus") {
      if (act.index === 0) {
        s.pane = "left";
        s.dlDetail = null;
      } else if (s.torrents[s.dlCursor]) {
        s.pane = "right";
        s.dlFileCursor = 0;
        await loadDlDetail(s);
      }
    } else if (act.type === "cursor") {
      if (s.pane === "right" && s.dlDetail) {
        s.dlFileCursor = rightNav.pos;
      } else {
        s.dlCursor = leftNav.pos;
        await loadDlDetail(s);
      }
    }
    return;
  }

  // right pane action keys
  if (s.pane === "right" && s.dlDetail) {
    const tid = s.dlDetail.id;
    if (key === "3") {
      await transmission.setFilePriority(tid, [s.dlFileCursor], "high");
      await transmission.setFilesWanted(tid, [s.dlFileCursor], []);
      s.dlDetail = await transmission.getDetail(tid);
    } else if (key === "2") {
      await transmission.setFilePriority(tid, [s.dlFileCursor], "normal");
      await transmission.setFilesWanted(tid, [s.dlFileCursor], []);
      s.dlDetail = await transmission.getDetail(tid);
    } else if (key === "1") {
      await transmission.setFilePriority(tid, [s.dlFileCursor], "low");
      await transmission.setFilesWanted(tid, [s.dlFileCursor], []);
      s.dlDetail = await transmission.getDetail(tid);
    } else if (key === "0") {
      await transmission.setFilesWanted(tid, [], [s.dlFileCursor]);
      s.dlDetail = await transmission.getDetail(tid);
    } else if (key === "w") {
      const f = files[s.dlFileCursor];
      if (f && s.dlDetail.downloadDir) {
        const path = `${s.dlDetail.downloadDir}/${f.name}`;
        Bun.spawn(["xdg-open", path], { stdout: "ignore", stderr: "ignore" });
      }
    }
    return;
  }
  if (key === "x" && s.torrents[s.dlCursor]) {
    const t = s.torrents[s.dlCursor];
    await transmission.remove([t.id]);
    s.status = `Removed ${truncate(t.name, 40)}`;
    await refreshTorrents(s);
  } else if (key === "c") {
    await doCleanup(s);
    await refreshTorrents(s);
  }
}

async function loadDlDetail(s: State) {
  const t = s.torrents[s.dlCursor];
  if (t) {
    s.dlDetail = await transmission.getDetail(t.id);
  } else {
    s.dlDetail = null;
  }
}

// main TUI

async function mediaTui() {
  const s = initState();

  const draw = () => {
    const { left, right } = renderPanels(s);
    const [leftW, rightW] = columnWidths([55, 45]);
    const gLabel = s.genreMode ? pc.cyan(pc.bold("g genres")) : pc.dim("g genres");
    const pLabel = s.profileMode ? pc.cyan(pc.bold("p profiles")) : pc.dim("p profiles");
    appShell({
      tabs: TABS,
      activeTab: TAB_ORDER.indexOf(s.tab),
      tabLeft: gLabel,
      tabRight: pLabel,
      toolbar: buildToolbar(s),
      panels: [
        { lines: left, scroll: s.leftScroll, focused: s.pane === "left", cursor: true },
        { lines: right, scroll: s.rightScroll, focused: s.pane === "right" },
      ],
      widths: [leftW, rightW],
      status: s.status,
      keys: getTabKeys(s),
    });
  };

  // initial loads
  loadTropes(s);
  lazyRegen(s, draw);
  refreshTorrents(s);
  loadListInfo(s, draw);
  draw();

  // poll downloads
  const interval = setInterval(async () => {
    await refreshTorrents(s);
    if (s.tab === "torrent") draw();
  }, 2000);

  return new Promise<void>((resolve) => {
    const cleanup = startRaw(async (key) => {
      const result = await handleKey(key, s, draw);
      if (result === "quit") {
        clearInterval(interval);
        cleanup();
        resolve();
        return;
      }
      draw();
    });
  });
}

// commander

export default function register(program: Command) {
  program
    .command("media")
    .description("Media browser: recommendations, watchlist, torrents & downloads")
    .action(mediaTui);
}
