import * as omdb from "./omdb.ts";
import * as tmdb from "./tmdb.ts";
import {
  getRatings, getWatchlist, getPrefs, getTropes,
  saveTrope, saveItem, linkItemTrope, setLastRegenTime,
  profileKey, db,
  type Trope,
} from "./db.ts";
import { stars } from "./interactive.ts";

interface TropeResult {
  name: string;
  emoji: string;
  description: string;
  titles: { title: string; year?: string; type?: string }[];
}

const TARGET_ITEMS = 15;
const OMDB_BUDGET = 250;
const OMDB_DELAY = 100;

async function callClaude(prompt: string): Promise<string> {
  const proc = Bun.spawn(
    ["claude", "-p", prompt, "--output-format", "json"],
    { stdout: "pipe", stderr: "pipe" },
  );
  const out = await new Response(proc.stdout).text();
  await proc.exited;

  let text = out.trim();
  try {
    const wrapper = JSON.parse(text);
    text = typeof wrapper === "string" ? wrapper : wrapper.result ?? text;
  } catch {
    // not wrapped
  }
  text = text.replace(/^```(?:json)?\s*\n?/m, "").replace(/\n?```\s*$/m, "").trim();
  return text;
}

function buildPrompt(
  profileIds: number[],
  existingTropes: Trope[],
  genreFilter?: string,
): string {
  const ratings = getRatings(profileIds);
  const watchlist = getWatchlist(profileIds);
  const prefs = profileIds.flatMap(id => getPrefs(id));

  const ratingsCtx = ratings.map(r =>
    `${r.title} (${r.year ?? "?"}) - ${stars(r.rating)} ${r.type ?? ""}`,
  ).join("\n");

  const prefsCtx = prefs.map(p => `${p.key}: ${p.value}`).join("\n");

  const existingNames = existingTropes.map(t => t.name);

  const excludeList = [
    ...ratings.map(r => `${r.title} (${r.year ?? "?"})`),
    ...watchlist.map(w => `${w.title} (${w.year ?? "?"})`),
  ];

  const parts = [
    ratingsCtx && `My ratings:\n${ratingsCtx}`,
    prefsCtx && `My preferences:\n${prefsCtx}`,
    existingNames.length && `Existing tropes (generate NEW ones, not these):\n${existingNames.join("\n")}`,
    excludeList.length && `DO NOT include any of these titles (already seen/on watchlist):\n${excludeList.join("\n")}`,
    genreFilter && `Focus on these genres: ${genreFilter}`,
    `Generate 10 new tropes (fine-grained hybrid subgenres like "Cerebral Sci-Fi Thrillers" or "Dark Scandinavian Crime Procedurals").`,
    `Each trope should have:`,
    `- "name": 3-6 words`,
    `- "emoji": a single emoji that captures the trope's vibe`,
    `- "description": 1 short sentence (max 80 chars)`,
    `- "titles": array of exactly 20 specific titles [{title, year, type}] where type is "movie" or "series"`,
    `Reply with ONLY a raw JSON array, no markdown fences.`,
    `Format: [{"name":"...","emoji":"...","description":"...","titles":[{"title":"...","year":"...","type":"movie|series"},...]},...]`,
  ].filter(Boolean);

  return parts.join("\n\n");
}

// resolve a single title via OMDb, returns item ID or null
async function resolveTitle(
  title: string, type?: string, year?: string,
): Promise<number | null> {
  // check local DB first
  const existing = db().query(
    "SELECT id FROM items WHERE LOWER(title) = LOWER(?) AND year = ?",
  ).get(title, year ?? null) as { id: number } | null;
  if (existing) return existing.id;

  const results = await omdb.resolve(title, type, year);
  if (!results[0]) return null;
  const item = await omdb.getById(results[0].imdbID);
  if (!item) return null;
  return saveItem(item);
}

// resolve a title by imdbID (for TMDB backfill)
async function resolveImdbId(imdbId: string): Promise<number | null> {
  const existing = db().query(
    "SELECT id FROM items WHERE imdb_id = ?",
  ).get(imdbId) as { id: number } | null;
  if (existing) return existing.id;

  const item = await omdb.getById(imdbId);
  if (!item) return null;
  return saveItem(item);
}

function tropeItemCount(tropeId: number): number {
  const row = db().query(
    "SELECT COUNT(*) as cnt FROM item_tropes WHERE trope_id = ?",
  ).get(tropeId) as { cnt: number };
  return row.cnt;
}

export async function regenerate(
  profileIds: number[],
  genreFilter?: string,
  onProgress?: (msg: string) => void,
): Promise<void> {
  const pKey = profileKey(profileIds);
  const existing = getTropes(pKey);

  onProgress?.("Generating tropes...");
  const prompt = buildPrompt(profileIds, existing, genreFilter);
  const text = await callClaude(prompt);

  let tropes: TropeResult[];
  const start = text.indexOf("[");
  const end = text.lastIndexOf("]");
  if (start === -1 || end === -1) {
    throw new Error("Claude did not return a JSON array");
  }
  tropes = JSON.parse(text.slice(start, end + 1));

  // phase 1: resolve Claude's titles via OMDb
  let calls = 0;
  const totalTitles = tropes.reduce((n, t) => n + t.titles.length, 0);
  let resolved = 0;
  const tropeIds: number[] = [];

  for (const trope of tropes) {
    const tropeId = saveTrope(trope.name, trope.description, pKey, trope.emoji ?? "");
    tropeIds.push(tropeId);

    for (const t of trope.titles) {
      if (calls >= OMDB_BUDGET) break;

      resolved++;
      onProgress?.(`Resolving titles (${resolved}/${totalTitles})...`);

      try {
        const localHit = db().query(
          "SELECT id FROM items WHERE LOWER(title) = LOWER(?) AND year = ?",
        ).get(t.title, t.year ?? null) as { id: number } | null;

        if (localHit) {
          linkItemTrope(localHit.id, tropeId);
        } else {
          const results = await omdb.resolve(t.title, t.type, t.year);
          calls++;
          if (results[0]) {
            // check if imdbID already cached
            const cached = db().query(
              "SELECT id FROM items WHERE imdb_id = ?",
            ).get(results[0].imdbID) as { id: number } | null;
            if (cached) {
              linkItemTrope(cached.id, tropeId);
            } else {
              const item = await omdb.getById(results[0].imdbID);
              calls++;
              if (item) {
                const itemId = saveItem(item);
                linkItemTrope(itemId, tropeId);
              }
              await Bun.sleep(OMDB_DELAY);
            }
          } else {
            await Bun.sleep(OMDB_DELAY);
          }
        }
      } catch {
        // skip failed lookups
      }
    }
  }

  // phase 2: backfill tropes under TARGET_ITEMS using TMDB similar titles
  onProgress?.("Backfilling with similar titles...");
  for (let ti = 0; ti < tropeIds.length; ti++) {
    const tropeId = tropeIds[ti];
    let count = tropeItemCount(tropeId);
    if (count >= TARGET_ITEMS) continue;

    // get imdb IDs of existing items in this trope as seeds
    const seeds = db().query(
      "SELECT i.imdb_id FROM item_tropes it JOIN items i ON it.item_id = i.id WHERE it.trope_id = ?",
    ).all(tropeId) as { imdb_id: string }[];

    const tried = new Set<string>();
    for (const seed of seeds) {
      if (count >= TARGET_ITEMS) break;
      tried.add(seed.imdb_id);

      try {
        const found = await tmdb.findByImdbId(seed.imdb_id);
        if (!found) continue;

        const similar = await tmdb.getSimilar(found.tmdbId, found.type);
        for (const sim of similar) {
          if (count >= TARGET_ITEMS || calls >= OMDB_BUDGET) break;

          onProgress?.(`Backfilling trope ${ti + 1}/${tropeIds.length} (${count}/${TARGET_ITEMS})...`);

          try {
            // search OMDb to get imdbID
            const results = await omdb.resolve(sim.title, sim.type, sim.year);
            calls++;
            if (!results[0] || tried.has(results[0].imdbID)) continue;
            tried.add(results[0].imdbID);

            // check not already linked
            const linked = db().query(
              "SELECT 1 FROM item_tropes it JOIN items i ON it.item_id = i.id WHERE it.trope_id = ? AND i.imdb_id = ?",
            ).get(tropeId, results[0].imdbID);
            if (linked) continue;

            // check if imdbID already cached
            const cached = db().query(
              "SELECT id FROM items WHERE imdb_id = ?",
            ).get(results[0].imdbID) as { id: number } | null;
            if (cached) {
              linkItemTrope(cached.id, tropeId);
              count++;
            } else {
              const item = await omdb.getById(results[0].imdbID);
              calls++;
              if (item) {
                const itemId = saveItem(item);
                linkItemTrope(itemId, tropeId);
                count++;
              }
              await Bun.sleep(OMDB_DELAY);
            }
          } catch {
            // skip
          }
        }
      } catch {
        // skip seed
      }
    }
  }

  setLastRegenTime(pKey);
  onProgress?.(`Generated ${tropes.length} tropes`);
}
