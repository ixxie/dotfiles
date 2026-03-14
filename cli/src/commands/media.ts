import type { Command } from "commander";
import pc from "picocolors";
import {
  clear, startRaw, menuBar, tabBar, renderSplit, wordWrap,
  truncVis, padTo, visWidth, stripAnsi,
  type Keys,
} from "../lib/tui.ts";
import * as searchLib from "../lib/search.ts";
import * as transmission from "../lib/transmission.ts";
import * as omdb from "../lib/omdb.ts";
import * as claude from "../lib/claude.ts";
import {
  saveItem, addToWatchlist, removeFromWatchlist,
  getRatings, getWatchlist, getPrefs, getRatingForImdb,
} from "../lib/db.ts";
import { truncate, fmtSpeed, fmtEta, progressBar, stars } from "../lib/interactive.ts";
import { config } from "../lib/config.ts";

// state

type Tab = "list" | "recommend" | "search" | "download";
const TAB_ORDER: Tab[] = ["list", "recommend", "search", "download"];

interface State {
  tab: Tab;
  prompt: string;
  promptActive: boolean;
  status: string;

  // recommend
  suggestions: claude.Suggestion[];
  sugCursor: number;
  sugLoading: boolean;
  sugInfo: omdb.OmdbItem | null;

  // list
  listMode: number;
  listCursor: number;
  listInfo: omdb.OmdbItem | null;

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
}

function initState(): State {
  return {
    tab: "list", prompt: "", promptActive: false, status: "",
    suggestions: [], sugCursor: 0, sugLoading: false, sugInfo: null,
    listMode: 0, listCursor: 0, listInfo: null,
    searchResults: [], searchCursor: 0, searchLoading: false, searchBest: -1,
    torrents: [], dlCursor: 0, dlDetail: null, dlFileCursor: 0, dlFocusFiles: false,
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

  const ratings = getRatings();
  const prefs = getPrefs();
  const ratingsCtx = ratings.map(r =>
    `${r.title} (${r.year ?? "?"}) - ${stars(r.rating)} ${r.type ?? ""}`
  ).join("\n");
  const prefsCtx = prefs.map(p => `${p.key}: ${p.value}`).join("\n");

  claude.suggest(ratingsCtx, prefsCtx, s.prompt || undefined)
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

function infoLines(item: omdb.OmdbItem | null, width: number): string[] {
  if (!item) return [pc.dim("No info")];
  const lines: string[] = [];
  lines.push(pc.bold(item.Title) + ` (${item.Year ?? "?"})`);
  lines.push(`${item.Type ?? "?"}  \u2022  ${item.Runtime ?? "?"}`);
  lines.push("");
  if (item.Genre) lines.push(pc.dim("Genre: ") + item.Genre);
  if (item.Director && item.Director !== "N/A") lines.push(pc.dim("Dir: ") + item.Director);
  if (item.Actors) lines.push(pc.dim("Cast: ") + truncate(item.Actors, width - 6));
  if (item.imdbRating) lines.push(pc.dim("IMDb: ") + pc.yellow(item.imdbRating + "/10"));
  const rating = getRatingForImdb(item.imdbID);
  if (rating) lines.push(pc.dim("You: ") + pc.yellow(stars(rating.rating)));
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

  // tab bar
  console.log();
  console.log(tabBar(TAB_LABELS, TAB_ORDER.indexOf(s.tab)));
  console.log();

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
      right = infoLines(s.sugInfo, rightW);
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
    case "list": {
      const modeLabel = s.listMode === 0 ? "Watchlist" : "Ratings";
      const otherLabel = s.listMode === 0 ? "Ratings" : "Watchlist";
      left.push(`  ${pc.bold(pc.underline(modeLabel))}  ${pc.dim(otherLabel)}`);
      left.push("");

      if (s.listMode === 0) {
        const items = getWatchlist();
        if (!items.length) {
          left.push(pc.dim("  Empty"));
        } else {
          for (let i = 0; i < items.length; i++) {
            const it = items[i];
            const prefix = i === s.listCursor ? pc.yellow("\u25B6 ") : "  ";
            left.push(`${prefix}${it.title} ${pc.dim(`(${it.year ?? "?"})`)}`);
            left.push(`    ${pc.dim(it.type ?? "")}  ${pc.dim(it.genre ?? "")}`);
          }
        }
      } else {
        const items = getRatings();
        if (!items.length) {
          left.push(pc.dim("  No ratings"));
        } else {
          for (let i = 0; i < items.length; i++) {
            const it = items[i];
            const prefix = i === s.listCursor ? pc.yellow("\u25B6 ") : "  ";
            left.push(`${prefix}${pc.yellow(stars(it.rating))} ${it.title} ${pc.dim(`(${it.year ?? "?"})`)}`);
          }
        }
      }
      right = infoLines(s.listInfo, rightW);
      break;
    }
  }

  // viewport: scroll and pad to fill terminal height
  const rows = process.stdout.rows ?? 24;
  let used = 3; // blank + tab bar + blank line after it
  if (s.promptActive) used += 2;
  if (s.status) used += 2;
  used += 2; // menu bar
  const contentH = Math.max(1, rows - used);

  // scroll panes to keep cursor visible
  const scrollCtx = Math.floor(contentH / 3);

  const leftCursor = left.findIndex(l => l.includes("\u25B6"));
  let lOff = 0;
  if (leftCursor >= 0 && left.length > contentH) {
    lOff = Math.max(0, leftCursor - scrollCtx);
    lOff = Math.min(lOff, left.length - contentH);
  }

  const rightCursor = right.findIndex(l => l.includes("\u25B6"));
  let rOff = 0;
  if (rightCursor >= 0 && right.length > contentH) {
    rOff = Math.max(0, rightCursor - scrollCtx);
    rOff = Math.min(rOff, right.length - contentH);
  }

  const leftView = left.slice(lOff, lOff + contentH);
  const rightView = right.slice(rOff, rOff + contentH);

  while (leftView.length < contentH) leftView.push("");
  while (rightView.length < contentH) rightView.push("");

  renderSplit(leftView, rightView, leftW);
}

// key handling

function getTabKeys(s: State): Keys {
  const nav: Keys = [["left", "prev tab"], ["right", "next tab"]];

  switch (s.tab) {
    case "recommend": return [...nav, ["/", "query"], ["up", "up"], ["down", "down"], ["enter", "search"], ["t", "trailer"], ["esc", "quit"]];
    case "search": return [...nav, ["/", "query"], ["up", "up"], ["down", "down"], ["enter", "add"], ["esc", "quit"]];
    case "download":
      if (s.dlFocusFiles) {
        return [["up", "up"], ["down", "down"], ["3", "high"], ["2", "med"], ["1", "low"], ["0", "off"], ["w", "watch"], ["esc", "back"]];
      }
      return [...nav, ["up", "up"], ["down", "down"], ["enter", "files"], ["backspace", "remove"], ["c", "cleanup"], ["esc", "quit"]];
    case "list": return [...nav, ["tab", "mode"], ["up", "up"], ["down", "down"], ["enter", "search"], ["t", "trailer"], ["backspace", "remove"], ["esc", "quit"]];
    default: return nav;
  }
}

async function handleKey(key: string, s: State, draw: () => void): Promise<"quit" | void> {
  // prompt mode
  if (s.promptActive) {
    if (key === "esc") {
      s.promptActive = false;
    } else if (key === "enter") {
      s.promptActive = false;
      if (s.tab === "recommend") loadSuggestions(s, draw);
      else if (s.tab === "search") loadSearch(s, draw);
    } else if (key === "backspace") {
      s.prompt = s.prompt.slice(0, -1);
      if (s.tab === "recommend") {
        if (debounceTimer) clearTimeout(debounceTimer);
        debounceTimer = setTimeout(() => loadSuggestions(s, draw), 1000);
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
    if (s.tab === "download") s.dlFocusFiles = false;
    return;
  }
  if (key === "right" && ti < TAB_ORDER.length - 1 && !(s.tab === "download" && s.dlFocusFiles)) {
    s.tab = TAB_ORDER[ti + 1];
    s.status = "";
    if (s.tab === "download") s.dlFocusFiles = false;
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
    case "recommend": return handleRecommend(key, s, draw);
    case "search": return handleSearch(key, s, draw);
    case "download": return handleDownload(key, s, draw);
    case "list": return handleList(key, s, draw);
  }
}

function handleRecommend(key: string, s: State, draw: () => void) {
  if (key === "up" && s.sugCursor > 0) {
    s.sugCursor--;
    loadSugInfo(s, draw);
  } else if (key === "down" && s.sugCursor < s.suggestions.length - 1) {
    s.sugCursor++;
    loadSugInfo(s, draw);
  } else if (key === "enter" && s.suggestions[s.sugCursor]) {
    const sg = s.suggestions[s.sugCursor];
    // add to watchlist via OMDB
    omdb.resolve(sg.title).then(async results => {
      if (results.length > 0) {
        const item = await omdb.getById(results[0].imdbID);
        if (item) {
          const id = saveItem(item);
          addToWatchlist(id);
        }
      }
    }).catch(() => {});
    // switch to search with title
    s.tab = "search";
    s.prompt = sg.title;
    loadSearch(s, draw);
  } else if (key === "t" && s.suggestions[s.sugCursor]) {
    const sg = s.suggestions[s.sugCursor];
    openTrailer(sg.title, sg.year);
  }
}

function loadSugInfo(s: State, draw: () => void) {
  const sg = s.suggestions[s.sugCursor];
  if (!sg) return;
  s.sugInfo = null;
  omdb.resolve(sg.title).then(async results => {
    if (results[0]) {
      const item = await omdb.getById(results[0].imdbID);
      s.sugInfo = item;
      draw();
    }
  }).catch(() => {});
}

function handleList(key: string, s: State, draw: () => void) {
  const items = s.listMode === 0 ? getWatchlist() : getRatings();

  if (key === "tab") {
    s.listMode = s.listMode === 0 ? 1 : 0;
    s.listCursor = 0;
    s.listInfo = null;
  } else if (key === "up" && s.listCursor > 0) {
    s.listCursor--;
    loadListInfo(s, draw);
  } else if (key === "down" && s.listCursor < items.length - 1) {
    s.listCursor++;
    loadListInfo(s, draw);
  } else if (key === "enter" && items[s.listCursor]) {
    const it = items[s.listCursor];
    s.tab = "search";
    s.prompt = it.title;
    loadSearch(s, draw);
  } else if (key === "t" && items[s.listCursor]) {
    const it = items[s.listCursor];
    openTrailer(it.title, it.year ?? undefined);
  } else if (key === "backspace" && s.listMode === 0) {
    const wl = getWatchlist();
    if (wl[s.listCursor]) {
      removeFromWatchlist(wl[s.listCursor].imdb_id);
      s.status = `Removed ${wl[s.listCursor].title}`;
      if (s.listCursor >= getWatchlist().length) s.listCursor = Math.max(0, getWatchlist().length - 1);
    }
  }
}

function loadListInfo(s: State, draw: () => void) {
  const items = s.listMode === 0 ? getWatchlist() : getRatings();
  const it = items[s.listCursor];
  if (!it) return;
  s.listInfo = null;
  fetchInfo(it.imdb_id, item => { s.listInfo = item; }, draw);
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
  };

  // initial loads
  loadSuggestions(s, draw);
  refreshTorrents(s);
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
