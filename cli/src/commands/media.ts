import type { Command } from "commander";
import pc from "picocolors";
import { select, tui } from "../lib/tui.ts";
import { log, error } from "../utils.ts";
import * as search from "../lib/search.ts";
import * as transmission from "../lib/transmission.ts";
import * as omdb from "../lib/omdb.ts";
import * as claude from "../lib/claude.ts";
import { saveItem, upsertRating, addToWatchlist, getRatings, getWatchlist, getPrefs, getRatingForImdb } from "../lib/db.ts";
import { truncate, fmtBytes, fmtSpeed, fmtEta, progressBar, stars } from "../lib/interactive.ts";
import { config } from "../lib/config.ts";

async function pickOmdb(title: string): Promise<omdb.OmdbItem | null> {
  const results = await omdb.resolve(title);
  if (results.length === 0) {
    error("No results found on OMDb");
    return null;
  }

  if (results.length === 1) {
    return omdb.getById(results[0].imdbID);
  }

  const choice = await select({
    message: "Which title?",
    items: results.map(r => ({
      name: `${r.Title} (${r.Year}) [${r.Type}]`,
      value: r.imdbID,
    })),
  });
  if (!choice) return null;

  return omdb.getById(choice);
}

async function cmdSearch(query: string[]) {
  const q = query.join(" ");
  log("\u{1F50D}", `Searching for ${pc.white(q)}...`);

  let results: search.Result[];
  try {
    results = await search.search(q);
  } catch (e) {
    error(`Jackett search failed: ${(e as Error).message}`);
    process.exit(1);
  }

  if (results.length === 0) {
    error("No results found");
    process.exit(1);
  }

  const choice = await select({
    message: "Pick a torrent to add",
    items: results.map((r, i) => ({
      name: `${pc.green(String(r.seeds).padStart(4))} ${pc.cyan(String(r.peers).padStart(4))} ${pc.magenta(r.size.padEnd(8))} ${truncate(r.title, 58)}`,
      value: i,
    })),
    pageSize: 20,
  });
  if (choice === null) return;

  const chosen = results[choice];
  log("\u{1F4E5}", `Adding ${pc.white(truncate(chosen.title, 60))}...`);

  try {
    await transmission.add(chosen.magnet);
    console.log(pc.green("  Added to Transmission!"));
  } catch (e) {
    error(`Failed to add torrent: ${(e as Error).message}`);
    process.exit(1);
  }
}

async function cmdTorrents() {
  const state = { cursor: 0, torrents: [] as transmission.Torrent[] };

  const refresh = async (s: typeof state) => {
    try {
      s.torrents = await transmission.list();
      if (s.cursor >= s.torrents.length) s.cursor = Math.max(0, s.torrents.length - 1);
    } catch {}
  };

  await refresh(state);

  await tui({
    state,
    render: (s) => {
      console.log(pc.bold(" Torrents\n"));
      if (s.torrents.length === 0) {
        console.log(pc.dim("  No active torrents."));
      } else {
        for (let i = 0; i < s.torrents.length; i++) {
          const t = s.torrents[i];
          const prefix = i === s.cursor ? pc.yellow("\u25B6 ") : "  ";
          const status = transmission.STATUS[t.status] ?? "Unknown";
          const name = truncate(t.name, 50);
          const prog = progressBar(t.percentDone);
          const dl = fmtSpeed(t.rateDownload);
          const ul = fmtSpeed(t.rateUpload);
          const eta = t.eta > 0 ? fmtEta(t.eta) : "";
          const ratio = t.uploadRatio >= 0 ? t.uploadRatio.toFixed(2) : "-.--";
          console.log(`${prefix}${name}`);
          console.log(`    ${prog}  ${pc.dim(status)}  ${pc.cyan("\u2193" + dl)}  ${pc.green("\u2191" + ul)}  ${pc.yellow("R:" + ratio)}  ${eta ? pc.dim(eta) : ""}`);
          if (i < s.torrents.length - 1) console.log();
        }
      }
    },
    keys: [
      ["up", "up"], ["down", "down"],
      ["p", "pause"], ["r", "resume"], ["d", "delete"], ["c", "cleanup"],
    ],
    onKey: async (key, s) => {
      const t = s.torrents[s.cursor];
      if (key === "up" && s.cursor > 0) s.cursor--;
      else if (key === "down" && s.cursor < s.torrents.length - 1) s.cursor++;
      else if (key === "p" && t) await transmission.pause([t.id]);
      else if (key === "r" && t) await transmission.resume([t.id]);
      else if (key === "d" && t) await transmission.remove([t.id]);
      else if (key === "c") await doCleanup();
      await refresh(s);
    },
    poll: { fn: refresh, ms: 2000 },
  });
}

async function doCleanup(): Promise<number> {
  const threshold = config().cleanupRatio ?? 1.2;
  const torrents = await transmission.list();
  const removable = torrents.filter(t =>
    t.percentDone >= 1 && t.uploadRatio >= threshold
  );
  if (removable.length > 0) {
    await transmission.remove(removable.map(t => t.id));
  }
  return removable.length;
}

async function cmdCleanup() {
  const threshold = config().cleanupRatio ?? 1.2;
  log("\u{1F9F9}", `Removing completed torrents with ratio >= ${threshold}...`);
  const count = await doCleanup();
  if (count === 0) {
    console.log(pc.dim("  Nothing to clean up."));
  } else {
    console.log(pc.green(`  Removed ${count} torrent${count > 1 ? "s" : ""}.`));
  }
}

async function cmdSuggest(prompt?: string[]) {
  const ratings = getRatings();
  const prefs = getPrefs();

  const ratingsCtx = ratings.map(r =>
    `${r.title} (${r.year ?? "?"}) - ${stars(r.rating)} ${r.type ?? ""}`
  ).join("\n");

  const prefsCtx = prefs.map(p => `${p.key}: ${p.value}`).join("\n");
  const userPrompt = prompt?.length ? prompt.join(" ") : undefined;

  log("\u{1F916}", "Asking Claude for suggestions...");
  let suggestions: claude.Suggestion[];
  try {
    suggestions = await claude.suggest(ratingsCtx, prefsCtx, userPrompt);
  } catch (e) {
    error(`Claude suggestion failed: ${(e as Error).message}`);
    process.exit(1);
  }

  if (suggestions.length === 0) {
    error("No suggestions returned");
    return;
  }

  const state = { cursor: 0, saved: new Set<number>() };

  await tui({
    state,
    render: (s) => {
      console.log(pc.bold(" Suggestions\n"));
      for (let i = 0; i < suggestions.length; i++) {
        const sg = suggestions[i];
        const prefix = i === s.cursor ? pc.yellow("\u25B6 ") : "  ";
        const tag = s.saved.has(i) ? ` ${pc.green("[saved]")}` : "";
        console.log(`${prefix}${pc.bold(sg.title)} (${sg.year ?? "?"}) [${sg.type ?? "?"}]${tag}`);
        console.log(`    ${pc.dim(sg.reason)}`);
        if (i < suggestions.length - 1) console.log();
      }
    },
    keys: [
      ["up", "up"], ["down", "down"],
      ["i", "info"], ["s", "save"], ["t", "torrent"],
    ],
    onKey: async (key, s) => {
      const sg = suggestions[s.cursor];
      if (key === "up" && s.cursor > 0) s.cursor--;
      else if (key === "down" && s.cursor < suggestions.length - 1) s.cursor++;
      else if (key === "i" && sg) await cmdInfo([sg.title]);
      else if (key === "s" && sg) { await cmdSave([sg.title]); s.saved.add(s.cursor); }
      else if (key === "t" && sg) await cmdSearch([sg.title]);
    },
  });
}

async function cmdRate(args: string[]) {
  if (args.length < 2) {
    error("Usage: yo media rate <title> <1-5>");
    process.exit(1);
  }

  const rating = parseInt(args[args.length - 1]);
  if (isNaN(rating) || rating < 1 || rating > 5) {
    error("Rating must be 1-5");
    process.exit(1);
  }

  const title = args.slice(0, -1).join(" ");
  const data = await pickOmdb(title);
  if (!data) return;

  const itemId = saveItem(data);
  upsertRating(itemId, rating);
  console.log(pc.green(`  Rated ${data.Title}: ${stars(rating)} (${rating}/5)`));
}

async function cmdSave(args: string[]) {
  const title = args.join(" ");
  if (!title) {
    error("Usage: yo media save <title>");
    process.exit(1);
  }

  const data = await pickOmdb(title);
  if (!data) return;

  const itemId = saveItem(data);
  addToWatchlist(itemId);
  console.log(pc.green(`  Added ${data.Title} to watchlist`));
}

async function cmdList() {
  const state = { tab: 0, cursor: 0 };

  await tui({
    state,
    render: (s) => {
      const tabs = [
        s.tab === 0 ? pc.bold(pc.underline("Watchlist")) : pc.dim("Watchlist"),
        s.tab === 1 ? pc.bold(pc.underline("Ratings")) : pc.dim("Ratings"),
      ];
      console.log(` ${tabs.join("  |  ")}\n`);

      if (s.tab === 0) {
        const items = getWatchlist();
        if (items.length === 0) {
          console.log(pc.dim("  Watchlist empty."));
        } else {
          for (let i = 0; i < items.length; i++) {
            const it = items[i];
            const prefix = i === s.cursor ? pc.yellow("\u25B6 ") : "  ";
            console.log(`${prefix}${it.title} ${pc.dim(`(${it.year ?? "?"})`)}`);
            console.log(`    ${pc.dim(it.type ?? "")}  ${pc.dim(it.genre ?? "")}`);
          }
        }
      } else {
        const items = getRatings();
        if (items.length === 0) {
          console.log(pc.dim("  No ratings yet."));
        } else {
          for (let i = 0; i < items.length; i++) {
            const it = items[i];
            const prefix = i === s.cursor ? pc.yellow("\u25B6 ") : "  ";
            console.log(`${prefix}${pc.yellow(stars(it.rating))} ${it.title} ${pc.dim(`(${it.year ?? "?"})`)}`);
            console.log(`    ${pc.dim(it.type ?? "")}  ${pc.dim(it.genre ?? "")}`);
          }
        }
      }
    },
    keys: [
      ["left", "tab"], ["right", "tab"],
      ["up", "up"], ["down", "down"],
    ],
    onKey: (key, s) => {
      const items = s.tab === 0 ? getWatchlist() : getRatings();
      if (key === "left" || key === "right") { s.tab = s.tab === 0 ? 1 : 0; s.cursor = 0; }
      else if (key === "up" && s.cursor > 0) s.cursor--;
      else if (key === "down" && s.cursor < items.length - 1) s.cursor++;
    },
  });
}

async function cmdInfo(args: string[]) {
  const title = args.join(" ");
  if (!title) {
    error("Usage: yo media info <title|imdbId>");
    process.exit(1);
  }

  let data: omdb.OmdbItem | null;
  if (title.startsWith("tt")) {
    data = await omdb.getById(title);
  } else {
    data = await pickOmdb(title);
  }

  if (!data) {
    error("Not found on OMDb");
    return;
  }

  saveItem(data);

  // show poster if available
  if (data.Poster && data.Poster !== "N/A") {
    try {
      const tmpDir = process.env.TMPDIR ?? "/tmp";
      const posterPath = `${tmpDir}/yo-poster-${data.imdbID}.jpg`;
      const res = await fetch(data.Poster);
      if (res.ok) {
        await Bun.write(posterPath, await res.arrayBuffer());
        const viu = Bun.spawnSync(["viu", "-w", "40", posterPath], {
          stdout: "inherit",
          stderr: "ignore",
        });
      }
    } catch {
      // poster display is best-effort
    }
  }

  console.log();
  console.log(`${pc.bold(data.Title)} (${data.Year ?? "?"})`);
  console.log(`  Type: ${data.Type}  |  Runtime: ${data.Runtime}`);
  console.log(`  Genre: ${data.Genre}`);
  console.log(`  Director: ${data.Director}`);
  console.log(`  Actors: ${data.Actors}`);
  console.log(`  IMDb: ${data.imdbRating}/10`);
  console.log(`\n  ${data.Plot ?? "No plot available."}\n`);

  const rating = getRatingForImdb(data.imdbID);
  if (rating) {
    console.log(`  ${pc.yellow(`Your rating: ${stars(rating.rating)} (${rating.rating}/5)`)}`);
    if (rating.notes) console.log(`  Notes: ${rating.notes}`);
  }
}

function cmdPrefs() {
  const prefs = getPrefs();
  if (prefs.length === 0) {
    console.log(pc.dim("  No preferences set."));
    return;
  }
  for (const p of prefs) {
    console.log(`  ${pc.bold(p.key)}: ${p.value}`);
  }
}

export default function register(program: Command) {
  const media = program
    .command("media")
    .description("Media search, torrents, ratings & recommendations");

  media
    .command("search <query...>")
    .description("Search Jackett for torrents and add to Transmission")
    .action(cmdSearch);

  media
    .command("torrents")
    .description("Interactive torrent dashboard")
    .action(cmdTorrents);

  media
    .command("suggest [prompt...]")
    .description("Claude-powered media suggestions")
    .action(cmdSuggest);

  media
    .command("rate <args...>")
    .description("Rate a title (1-5): yo media rate <title> <rating>")
    .action(cmdRate);

  media
    .command("save <title...>")
    .description("Save a title to watchlist")
    .action(cmdSave);

  media
    .command("list")
    .description("Interactive tabbed view: watchlist | ratings")
    .action(cmdList);

  media
    .command("info <query...>")
    .description("Show OMDb details + your rating")
    .action(cmdInfo);

  media
    .command("prefs")
    .description("Show taste preferences")
    .action(cmdPrefs);

  media
    .command("cleanup")
    .description("Remove completed torrents above seed ratio threshold")
    .action(cmdCleanup);

}
