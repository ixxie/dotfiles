import type { Command } from "commander";
import pc from "picocolors";
import {
  clear, flush, startRaw, menuBar, tabBar, renderSplit, wordWrap,
  truncVis, padTo, visWidth, stripAnsi, input,
  type Keys,
} from "../lib/tui.ts";
import * as searchLib from "../lib/search.ts";
import * as transmission from "../lib/transmission.ts";
import * as omdb from "../lib/omdb.ts";
import * as claude from "../lib/claude.ts";
import {
  saveItem, upsertRating, addToWatchlist, removeFromWatchlist,
  getRatings, getWatchlist, getPrefs, getRatingForImdb,
  getProfiles, createProfile, type Profile,
} from "../lib/db.ts";
import { truncate, fmtSpeed, fmtEta, progressBar, stars } from "../lib/interactive.ts";
import { config } from "../lib/config.ts";

// state

type Tab = "genres" | "watchlist" | "ratings" | "recommend" | "search" | "download";
const TAB_ORDER: Tab[] = ["genres", "watchlist", "ratings", "recommend", "search", "download"];

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

function matchesGenres(genre: string | null | undefined, selected: Set<string>): boolean {
  if (!selected.size) return true;
  if (!genre) return false;
  const tags = genre.split(",").map(g => g.trim());
  return tags.some(g => selected.has(g));
}

interface State {
  tab: Tab;
  prompt: string;
  promptActive: boolean;
  status: string;

  // genres
  genres: string[];
  genreSelected: Set<string>;
  genreCursor: number;

  // recommend
  suggestions: claude.Suggestion[];
  sugCursor: number;
  sugLoading: boolean;
  sugInfo: omdb.OmdbItem | null;

  // watchlist / ratings
  wlCursor: number;
  wlInfo: omdb.OmdbItem | null;
  ratCursor: number;
  ratInfo: omdb.OmdbItem | null;

  // search
  searchResults: searchLib.Result[];
  searchCursor: number;
  searchLoading: boolean;
  searchBest: number;

  // download
  torrents: transmission.Torrent[];
  dlCursor: number;
  dlDetail: transmission.TorrentDetail | null;
  dlFileCursor: number;
  dlFocusFiles: boolean;

  // scroll offsets
  scrollLeft: number;
  scrollRight: number;

  // profiles
  profiles: Profile[];
  activeProfiles: Profile[];
  profileMode: boolean;
  profileCursor: number;
  profilePending: Set<number>;
}

function initState(): State {
  return {
    tab: "genres", prompt: "", promptActive: false, status: "",
    genres: allGenres(getProfiles().slice(0, 1).map(p => p.id)), genreSelected: new Set(), genreCursor: 0,
    suggestions: [], sugCursor: 0, sugLoading: false, sugInfo: null,
    wlCursor: 0, wlInfo: null, ratCursor: 0, ratInfo: null,
    searchResults: [], searchCursor: 0, searchLoading: false, searchBest: -1,
    torrents: [], dlCursor: 0, dlDetail: null, dlFileCursor: 0, dlFocusFiles: false,
    scrollLeft: 0, scrollRight: 0,
    profiles: getProfiles(),
    activeProfiles: getProfiles().slice(0, 1),
    profileMode: false,
    profileCursor: 0,
    profilePending: new Set([getProfiles()[0]?.id ?? 1]),
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

// async actions

let debounceTimer: ReturnType<typeof setTimeout> | null = null;

function loadSuggestions(s: State, draw: () => void) {
  s.sugLoading = true;
  if (s.tab === "recommend") {
    s.status = "Loading suggestions...";
    draw();
  }

  const ids = activeIds(s);
  const ratings = getRatings(ids);
  const watchlist = getWatchlist(ids);

  // build per-profile context for group mode
  let ratingsCtx: string;
  let prefsCtx: string;
  if (isGroup(s)) {
    const sections = s.activeProfiles.map(p => {
      const pRatings = ratings.filter(r => r.profile_id === p.id);
      const pPrefs = getPrefs(p.id);
      const rLines = pRatings.map(r =>
        `  ${r.title} (${r.year ?? "?"}) - ${stars(r.rating)} ${r.type ?? ""}`
      ).join("\n");
      const pLines = pPrefs.map(pr => `  ${pr.key}: ${pr.value}`).join("\n");
      return `${p.name}'s ratings:\n${rLines || "  (none)"}` +
        (pLines ? `\n${p.name}'s preferences:\n${pLines}` : "");
    });
    ratingsCtx = sections.join("\n\n");
    prefsCtx = "Recommending for a group watching together. Find common ground they'd all enjoy.";
  } else {
    ratingsCtx = ratings.map(r =>
      `${r.title} (${r.year ?? "?"}) - ${stars(r.rating)} ${r.type ?? ""}`
    ).join("\n");
    prefsCtx = getPrefs(ids[0]).map(p => `${p.key}: ${p.value}`).join("\n");
  }

  const excludeCtx = [
    ...ratings.map(r => `${r.title} (${r.year ?? "?"})`),
    ...watchlist.map(w => `${w.title} (${w.year ?? "?"})`),
  ].join("\n");

  const genreFilter = s.genreSelected.size
    ? `Focus on these genres: ${[...s.genreSelected].join(", ")}`
    : undefined;
  const prompt = [s.prompt, genreFilter].filter(Boolean).join(". ") || undefined;

  claude.suggest(ratingsCtx, prefsCtx, excludeCtx, prompt)
    .then(results => {
      s.suggestions = results;
      s.sugCursor = 0;
      s.sugInfo = null;
      if (s.tab === "recommend") s.status = `${results.length} suggestions`;
    })
    .catch(() => { if (s.tab === "recommend") s.status = "Suggestion failed"; })
    .finally(() => { s.sugLoading = false; draw(); });
}

function fetchInfo(imdbId: string, cb: (item: omdb.OmdbItem | null) => void, draw: () => void) {
  omdb.getById(imdbId).then(item => { cb(item); draw(); }).catch(() => {});
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
    if (s.dlFocusFiles && s.torrents[s.dlCursor]) {
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

const TAB_LABELS: string[] = [...TAB_ORDER];

function fmtSize(bytes: number): string {
  if (bytes >= 1e9) return (bytes / 1e9).toFixed(1) + " GB";
  if (bytes >= 1e6) return (bytes / 1e6).toFixed(0) + " MB";
  return (bytes / 1e3).toFixed(0) + " KB";
}

function infoLines(item: omdb.OmdbItem | null, width: number, s?: State): string[] {
  if (!item) return [pc.dim("No info")];
  const lines: string[] = [];
  lines.push(pc.bold(item.Title) + ` (${item.Year ?? "?"})`);
  lines.push(`${item.Type ?? "?"}  \u2022  ${item.Runtime ?? "?"}`);
  lines.push("");
  if (item.Genre) lines.push(pc.dim("Genre: ") + item.Genre);
  if (item.Director && item.Director !== "N/A") lines.push(pc.dim("Dir: ") + item.Director);
  if (item.Actors) lines.push(pc.dim("Cast: ") + truncate(item.Actors, width - 6));
  if (item.imdbRating) lines.push(pc.dim("IMDb: ") + pc.yellow(item.imdbRating + "/10"));
  const ids = s ? activeIds(s) : undefined;
  const ratings = getRatingForImdb(item.imdbID, ids);
  if (ratings.length) {
    if (s && isGroup(s)) {
      for (const r of ratings) {
        lines.push(pc.dim(`${profileName(s, r.profile_id)}: `) + pc.yellow(stars(r.rating)));
      }
    } else if (ratings[0]) {
      lines.push(pc.dim("You: ") + pc.yellow(stars(ratings[0].rating)));
    }
  }
  lines.push("");
  if (item.Plot && item.Plot !== "N/A") {
    lines.push(...wordWrap(item.Plot, width));
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
  const status = transmission.STATUS[d.status] ?? "Unknown";
  lines.push(pc.bold(status));
  lines.push(pc.dim("Speed: ") + pc.cyan("\u2193" + fmtSpeed(d.rateDownload)) + "  " + pc.green("\u2191" + fmtSpeed(d.rateUpload)));
  if (d.eta > 0) lines.push(pc.dim("ETA: ") + fmtEta(d.eta));
  lines.push(pc.dim("Ratio: ") + pc.yellow(d.uploadRatio >= 0 ? d.uploadRatio.toFixed(2) : "-.--"));
  lines.push(pc.dim("Size: ") + fmtSize(d.totalSize));
  lines.push("");
  if (d.files.length > 0) {
    lines.push(pc.bold("Files:"));
    for (let i = 0; i < d.files.length; i++) {
      const f = d.files[i];
      const stat = d.fileStats[i];
      const name = f.name.split("/").pop() ?? f.name;
      const prioColor = !stat.wanted ? pc.dim("OFF") :
        stat.priority === 1 ? pc.green("HIGH") :
        stat.priority === -1 ? pc.yellow("LOW") : pc.dim("NORM");
      const prefix = i === fileCursor ? pc.yellow("\u25B6 ") : "  ";
      const pct = f.length > 0 ? Math.round(f.bytesCompleted / f.length * 100) : 0;
      lines.push(`${prefix}${truncate(name, width - 26)} ${fmtSize(f.length).padStart(8)} [${prioColor}] ${pc.dim(pct + "%")}`);
    }
  }
  return lines;
}

function renderState(s: State) {
  const cols = process.stdout.columns ?? 100;
  const leftW = Math.floor(cols * 0.55);
  const rightW = cols - leftW - 3;

  // tab bar with nav arrows and profile indicator
  const ti = TAB_ORDER.indexOf(s.tab);
  const leftArrow = ti > 0 ? pc.bold("\u2190 ") : "  ";
  const rightArrow = ti < TAB_ORDER.length - 1 ? pc.bold(" \u2192") : "";
  const profileTag = isGroup(s)
    ? pc.magenta(`[${s.activeProfiles.map(p => p.name).join(" + ")}]`)
    : s.profiles.length > 1
      ? pc.dim(`[${s.activeProfiles[0].name}]`)
      : "";
  console.log();
  console.log(`${leftArrow}${tabBar(TAB_LABELS, ti)}${rightArrow}  ${profileTag}`);
  console.log();

  // profile bar
  if (s.profileMode) {
    console.log(`  ${profileBar(s)}\n`);
  }

  // prompt
  if (s.promptActive) {
    console.log(`  ${pc.cyan("/")} ${s.prompt}\u2588\n`);
  }

  // status
  if (s.status) {
    console.log(`  ${pc.dim(s.status)}\n`);
  }

  const left: string[] = [];
  let right: string[] = [];

  switch (s.tab) {
    case "genres": {
      if (!s.genres.length) {
        left.push(pc.dim("  No genres found"));
      } else {
        for (let i = 0; i < s.genres.length; i++) {
          const g = s.genres[i];
          const on = s.genreSelected.has(g);
          const prefix = i === s.genreCursor ? pc.yellow("\u25B6 ") : "  ";
          const check = on ? pc.green("\u25C9") : pc.dim("\u25CB");
          left.push(`${prefix}${check} ${g}`);
        }
      }
      const active = [...s.genreSelected];
      if (active.length) {
        right.push(pc.bold("Active filters:"));
        right.push("");
        for (const g of active) right.push(`  ${pc.green("\u2022")} ${g}`);
      } else {
        right.push(pc.dim("No genre filter active"));
        right.push("");
        right.push(pc.dim("Toggle genres to filter"));
        right.push(pc.dim("watchlist, ratings &"));
        right.push(pc.dim("recommendations"));
      }
      break;
    }
    case "recommend": {
      if (!s.suggestions.length && !s.sugLoading) {
        left.push(pc.dim("  Press / to set a mood, or wait for auto-suggest"));
      } else {
        for (let i = 0; i < s.suggestions.length; i++) {
          const sg = s.suggestions[i];
          const prefix = i === s.sugCursor ? pc.yellow("\u25B6 ") : "  ";
          left.push(`${prefix}${pc.bold(sg.title)} (${sg.year ?? "?"}) [${sg.type ?? "?"}]`);
          left.push(`    ${pc.dim(sg.reason)}`);
          if (i < s.suggestions.length - 1) left.push("");
        }
      }
      right = infoLines(s.sugInfo, rightW, s);
      break;
    }
    case "search": {
      if (s.searchLoading) {
        left.push(pc.dim("  Searching..."));
      } else if (!s.searchResults.length) {
        left.push(pc.dim("  Press / to search for torrents"));
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
      break;
    }
    case "download": {
      if (!s.torrents.length) {
        left.push(pc.dim("  No active downloads"));
      } else {
        for (let i = 0; i < s.torrents.length; i++) {
          const t = s.torrents[i];
          const prefix = i === s.dlCursor ? pc.yellow(s.dlFocusFiles ? "\u25CB " : "\u25B6 ") : "  ";
          const status = transmission.STATUS[t.status] ?? "?";
          left.push(`${prefix}${truncate(t.name, leftW - 4)}`);
          left.push(`    ${progressBar(t.percentDone)}  ${pc.dim(status)}  ${pc.cyan("\u2193" + fmtSpeed(t.rateDownload))}  ${pc.green("\u2191" + fmtSpeed(t.rateUpload))}`);
          if (i < s.torrents.length - 1) left.push("");
        }
      }
      const t = s.torrents[s.dlCursor];
      if (t && s.dlDetail) {
        right = dlInfoLines(s.dlDetail, rightW, s.dlFocusFiles ? s.dlFileCursor : -1);
      } else {
        right = [pc.dim("Select a torrent")];
      }
      break;
    }
    case "watchlist": {
      const items = filteredWatchlist(s);
      if (!items.length) {
        left.push(pc.dim(s.genreSelected.size ? "  No matches for selected genres" : "  Empty"));
      } else {
        for (let i = 0; i < items.length; i++) {
          const it = items[i];
          const prefix = i === s.wlCursor ? pc.yellow("\u25B6 ") : "  ";
          const owner = isGroup(s) ? pc.magenta(` [${profileName(s, it.profile_id)}]`) : "";
          left.push(`${prefix}${it.title} ${pc.dim(`(${it.year ?? "?"})`)}${owner}`);
          left.push(`    ${pc.dim(it.type ?? "")}  ${pc.dim(it.genre ?? "")}`);
        }
      }
      right = infoLines(s.wlInfo, rightW, s);
      break;
    }
    case "ratings": {
      const items = filteredRatings(s);
      if (!items.length) {
        left.push(pc.dim(s.genreSelected.size ? "  No matches for selected genres" : "  No ratings"));
      } else {
        for (let i = 0; i < items.length; i++) {
          const it = items[i];
          const prefix = i === s.ratCursor ? pc.yellow("\u25B6 ") : "  ";
          const owner = isGroup(s) ? pc.magenta(` [${profileName(s, it.profile_id)}]`) : "";
          left.push(`${prefix}${pc.yellow(stars(it.rating))} ${it.title} ${pc.dim(`(${it.year ?? "?"})`)}${owner}`);
        }
      }
      right = infoLines(s.ratInfo, rightW, s);
      break;
    }
  }

  // viewport: scroll and pad to fill terminal height
  const rows = process.stdout.rows ?? 24;
  let used = 3; // blank + tab bar + blank line after it
  if (s.profileMode) used += 2;
  if (s.promptActive) used += 2;
  if (s.status) used += 2;
  used += 2; // menu bar
  const contentH = Math.max(1, rows - used);

  // scroll panes: only adjust when cursor leaves viewport
  const margin = 2;

  const leftCursor = left.findIndex(l => l.includes("\u25B6"));
  if (left.length <= contentH) {
    s.scrollLeft = 0;
  } else if (leftCursor >= 0) {
    if (leftCursor < s.scrollLeft + margin) {
      s.scrollLeft = Math.max(0, leftCursor - margin);
    } else if (leftCursor >= s.scrollLeft + contentH - margin) {
      s.scrollLeft = Math.min(left.length - contentH, leftCursor - contentH + margin + 1);
    }
  }

  const rightCursor = right.findIndex(l => l.includes("\u25B6"));
  if (right.length <= contentH) {
    s.scrollRight = 0;
  } else if (rightCursor >= 0) {
    if (rightCursor < s.scrollRight + margin) {
      s.scrollRight = Math.max(0, rightCursor - margin);
    } else if (rightCursor >= s.scrollRight + contentH - margin) {
      s.scrollRight = Math.min(right.length - contentH, rightCursor - contentH + margin + 1);
    }
  }

  const leftView = left.slice(s.scrollLeft, s.scrollLeft + contentH);
  const rightView = right.slice(s.scrollRight, s.scrollRight + contentH);

  while (leftView.length < contentH) leftView.push("");
  while (rightView.length < contentH) rightView.push("");

  renderSplit(leftView, rightView, leftW);
}

// key handling

function profileBar(s: State): string {
  return s.profiles.map((p, i) => {
    const on = s.profilePending.has(p.id);
    const check = on ? pc.green("\u25C9") : pc.dim("\u25CB");
    const name = i === s.profileCursor ? pc.yellow(pc.bold(p.name)) : p.name;
    return `${check} ${name}`;
  }).join("  ") + "  " + pc.cyan("+ new");
}

function getTabKeys(s: State): Keys {
  if (s.profileMode) {
    return [["left", ""], ["right", ""], [" ", "toggle"], ["+", "new"], ["enter", "confirm"], ["esc", "cancel"]];
  }

  const arrows: Keys = [["up", ""], ["down", ""]];
  const prof: Keys = [["p", "profiles"]];

  switch (s.tab) {
    case "genres": return [...arrows, ["enter", "toggle"], ...prof, ["esc", "quit"]];
    case "recommend": return [...arrows, ["/", "query"], ["1-5", "rate"], ["w", "watchlist"], ["enter", "search"], ["t", "trailer"], ...prof, ["esc", "quit"]];
    case "search": return [...arrows, ["/", "query"], ["enter", "add"], ...prof, ["esc", "quit"]];
    case "download":
      if (s.dlFocusFiles) {
        return [...arrows, ["3", "high"], ["2", "med"], ["1", "low"], ["0", "off"], ["w", "watch"], ["esc", "back"]];
      }
      return [...arrows, ["enter", "files"], ["backspace", "remove"], ["c", "cleanup"], ...prof, ["esc", "quit"]];
    case "watchlist": return [...arrows, ["enter", "search"], ["t", "trailer"], ["backspace", "remove"], ...prof, ["esc", "quit"]];
    case "ratings": return [...arrows, ["enter", "search"], ["t", "trailer"], ...prof, ["esc", "quit"]];
    default: return [...arrows, ...prof, ["esc", "quit"]];
  }
}

async function handleKey(key: string, s: State, draw: () => void): Promise<"quit" | void> {
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
      }
      s.profileMode = false;
      s.genres = allGenres(activeIds(s));
      s.genreSelected.clear();
      s.wlCursor = 0; s.wlInfo = null;
      s.ratCursor = 0; s.ratInfo = null;
      loadSuggestions(s, draw);
      s.status = `Profiles: ${s.activeProfiles.map(p => p.name).join(", ")}`;
    }
    return;
  }

  // prompt mode
  if (s.promptActive) {
    if (key === "esc") {
      s.promptActive = false;
    } else if (key === "enter") {
      s.promptActive = false;
      if (s.tab === "recommend" && s.prompt) loadSuggestions(s, draw);
      else if (s.tab === "search") loadSearch(s, draw);
    } else if (key === "backspace") {
      s.prompt = s.prompt.slice(0, -1);
      if (s.tab === "recommend") {
        if (debounceTimer) clearTimeout(debounceTimer);
        if (s.prompt) debounceTimer = setTimeout(() => loadSuggestions(s, draw), 1000);
      }
    } else if (key.length === 1 && key >= " ") {
      s.prompt += key;
      if (s.tab === "recommend") {
        if (debounceTimer) clearTimeout(debounceTimer);
        debounceTimer = setTimeout(() => loadSuggestions(s, draw), 1000);
      }
    }
    return;
  }

  // tab switching with left/right
  const ti = TAB_ORDER.indexOf(s.tab);
  if (key === "left" && ti > 0 && !(s.tab === "download" && s.dlFocusFiles)) {
    s.tab = TAB_ORDER[ti - 1];
    s.status = "";
    s.scrollLeft = 0; s.scrollRight = 0;
    if (s.tab === "download") s.dlFocusFiles = false;
    if (s.tab === "watchlist") loadWlInfo(s, draw);
    if (s.tab === "ratings") loadRatInfo(s, draw);
    return;
  }
  if (key === "right" && ti < TAB_ORDER.length - 1 && !(s.tab === "download" && s.dlFocusFiles)) {
    s.tab = TAB_ORDER[ti + 1];
    s.status = "";
    s.scrollLeft = 0; s.scrollRight = 0;
    if (s.tab === "download") s.dlFocusFiles = false;
    if (s.tab === "watchlist") loadWlInfo(s, draw);
    if (s.tab === "ratings") loadRatInfo(s, draw);
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
  if (key === "/" && (s.tab === "recommend" || s.tab === "search")) {
    s.promptActive = true;
    s.prompt = "";
    return;
  }

  // quit
  if (key === "q" || (key === "esc" && !(s.tab === "download" && s.dlFocusFiles))) return "quit";

  // tab-specific keys
  switch (s.tab) {
    case "genres": return handleGenres(key, s, draw);
    case "recommend": return handleRecommend(key, s, draw);
    case "search": return handleSearch(key, s, draw);
    case "download": return handleDownload(key, s, draw);
    case "watchlist": return handleWatchlist(key, s, draw);
    case "ratings": return handleRatings(key, s, draw);
  }
}

function handleGenres(key: string, s: State, draw: () => void) {
  if (key === "up" && s.genreCursor > 0) {
    s.genreCursor--;
  } else if (key === "down" && s.genreCursor < s.genres.length - 1) {
    s.genreCursor++;
  } else if (key === "enter" && s.genres[s.genreCursor]) {
    const g = s.genres[s.genreCursor];
    if (s.genreSelected.has(g)) {
      s.genreSelected.delete(g);
    } else {
      s.genreSelected.add(g);
    }
    // reset cursors since filtered lists changed
    s.wlCursor = 0; s.wlInfo = null;
    s.ratCursor = 0; s.ratInfo = null;
    // reload recommendations with new genre filter
    loadSuggestions(s, draw);
  }
}

function handleRecommend(key: string, s: State, draw: () => void) {
  if (key === "up" && s.sugCursor > 0) {
    s.sugCursor--;
    loadSugInfo(s, draw);
  } else if (key === "down" && s.sugCursor < s.suggestions.length - 1) {
    s.sugCursor++;
    loadSugInfo(s, draw);
  } else if (key === "w" && s.suggestions[s.sugCursor]) {
    const sg = s.suggestions[s.sugCursor];
    omdb.resolve(sg.title, sg.type, sg.year).then(async results => {
      if (results.length > 0) {
        const item = await omdb.getById(results[0].imdbID);
        if (item) {
          const id = saveItem(item);
          for (const pid of activeIds(s)) addToWatchlist(id, pid);
          s.status = `Added ${sg.title} to watchlist`;
          draw();
        }
      }
    }).catch(() => {});
  } else if (key === "enter" && s.suggestions[s.sugCursor]) {
    const sg = s.suggestions[s.sugCursor];
    s.tab = "search";
    s.prompt = sg.title;
    loadSearch(s, draw);
  } else if (key === "t" && s.suggestions[s.sugCursor]) {
    const sg = s.suggestions[s.sugCursor];
    openTrailer(sg.title, sg.year);
  } else if (key >= "1" && key <= "5" && s.suggestions[s.sugCursor]) {
    const sg = s.suggestions[s.sugCursor];
    const rating = parseInt(key);
    omdb.resolve(sg.title, sg.type, sg.year).then(async results => {
      if (results[0]) {
        const item = await omdb.getById(results[0].imdbID);
        if (item) {
          const id = saveItem(item);
          for (const pid of activeIds(s)) upsertRating(id, rating, pid);
          s.suggestions.splice(s.sugCursor, 1);
          if (s.sugCursor >= s.suggestions.length) s.sugCursor = Math.max(0, s.suggestions.length - 1);
          const names = s.activeProfiles.map(p => p.name).join(", ");
          s.status = `Rated ${sg.title} ${stars(rating)} for ${names}`;
          draw();
        }
      }
    }).catch(() => {});
  }
}

function loadSugInfo(s: State, draw: () => void) {
  const sg = s.suggestions[s.sugCursor];
  if (!sg) return;
  omdb.resolve(sg.title, sg.type, sg.year).then(async results => {
    if (results[0]) {
      const item = await omdb.getById(results[0].imdbID);
      s.sugInfo = item;
      draw();
    }
  }).catch(() => {});
}

function filteredWatchlist(s: State) {
  return getWatchlist(activeIds(s)).filter(it => matchesGenres(it.genre, s.genreSelected));
}

function filteredRatings(s: State) {
  return getRatings(activeIds(s)).filter(it => matchesGenres(it.genre, s.genreSelected));
}

function handleWatchlist(key: string, s: State, draw: () => void) {
  const items = filteredWatchlist(s);
  if (key === "up" && s.wlCursor > 0) {
    s.wlCursor--;
    loadWlInfo(s, draw);
  } else if (key === "down" && s.wlCursor < items.length - 1) {
    s.wlCursor++;
    loadWlInfo(s, draw);
  } else if (key === "enter" && items[s.wlCursor]) {
    s.tab = "search";
    s.prompt = items[s.wlCursor].title;
    loadSearch(s, draw);
  } else if (key === "t" && items[s.wlCursor]) {
    openTrailer(items[s.wlCursor].title, items[s.wlCursor].year ?? undefined);
  } else if (key === "backspace" && items[s.wlCursor]) {
    const it = items[s.wlCursor];
    // remove from the owning profile's watchlist
    removeFromWatchlist(it.imdb_id, it.profile_id);
    s.status = `Removed ${it.title}` + (isGroup(s) ? ` from ${profileName(s, it.profile_id)}` : "");
    const remaining = filteredWatchlist(s);
    if (s.wlCursor >= remaining.length) s.wlCursor = Math.max(0, remaining.length - 1);
    loadWlInfo(s, draw);
  }
}

function handleRatings(key: string, s: State, draw: () => void) {
  const items = filteredRatings(s);
  if (key === "up" && s.ratCursor > 0) {
    s.ratCursor--;
    loadRatInfo(s, draw);
  } else if (key === "down" && s.ratCursor < items.length - 1) {
    s.ratCursor++;
    loadRatInfo(s, draw);
  } else if (key === "enter" && items[s.ratCursor]) {
    s.tab = "search";
    s.prompt = items[s.ratCursor].title;
    loadSearch(s, draw);
  } else if (key === "t" && items[s.ratCursor]) {
    openTrailer(items[s.ratCursor].title, items[s.ratCursor].year ?? undefined);
  }
}

function loadWlInfo(s: State, draw: () => void) {
  const items = filteredWatchlist(s);
  const it = items[s.wlCursor];
  if (!it) return;
  fetchInfo(it.imdb_id, item => { s.wlInfo = item; }, draw);
}

function loadRatInfo(s: State, draw: () => void) {
  const items = filteredRatings(s);
  const it = items[s.ratCursor];
  if (!it) return;
  fetchInfo(it.imdb_id, item => { s.ratInfo = item; }, draw);
}

async function handleSearch(key: string, s: State, draw: () => void) {
  if (key === "up" && s.searchCursor > 0) {
    s.searchCursor--;
  } else if (key === "down" && s.searchCursor < s.searchResults.length - 1) {
    s.searchCursor++;
  } else if (key === "enter" && s.searchResults[s.searchCursor]) {
    const r = s.searchResults[s.searchCursor];
    s.status = `Adding ${truncate(r.title, 40)}...`;
    draw();
    try {
      await transmission.add(r.magnet);
      s.status = "Added to downloads";
      // switch to download tab
      await refreshTorrents(s);
      s.tab = "download";
      s.dlFocusFiles = false;
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
  if (s.dlFocusFiles && s.dlDetail) {
    const files = s.dlDetail.files;
    const tid = s.dlDetail.id;

    if (key === "esc") {
      s.dlFocusFiles = false;
      s.dlDetail = null;
    } else if (key === "up" && s.dlFileCursor > 0) {
      s.dlFileCursor--;
    } else if (key === "down" && s.dlFileCursor < files.length - 1) {
      s.dlFileCursor++;
    } else if (key === "3") {
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

  // torrent list view
  if (key === "up" && s.dlCursor > 0) {
    s.dlCursor--;
    await loadDlDetail(s);
  } else if (key === "down" && s.dlCursor < s.torrents.length - 1) {
    s.dlCursor++;
    await loadDlDetail(s);
  } else if (key === "enter" && s.torrents[s.dlCursor]) {
    s.dlFocusFiles = true;
    s.dlFileCursor = 0;
    await loadDlDetail(s);
  } else if (key === "backspace" && s.torrents[s.dlCursor]) {
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
    clear();
    renderState(s);
    menuBar(getTabKeys(s));
    flush();
  };

  // initial loads
  loadSuggestions(s, draw);
  refreshTorrents(s);
  loadWlInfo(s, draw);
  draw();

  // poll downloads
  const interval = setInterval(async () => {
    await refreshTorrents(s);
    if (s.tab === "download") draw();
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
