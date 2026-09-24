import { config } from "./config.ts";

export interface Result {
  title: string;
  seeds: number;
  peers: number;
  bytes: number;
  size: string;
  magnet: string;
  source: string;
  trusted?: boolean;
}

function vpnFetch(url: string, opts?: RequestInit): Promise<Response> {
  const proxy = config().proxy;
  const headers = { "User-Agent": "yo-media/0.1", ...(opts?.headers ?? {}) };
  return fetch(url, { ...opts, headers, ...(proxy ? { proxy } : {}) } as any);
}

function fmtSize(bytes: number): string {
  if (bytes >= 1e9) return (bytes / 1e9).toFixed(1) + " GB";
  if (bytes >= 1e6) return (bytes / 1e6).toFixed(0) + " MB";
  return (bytes / 1e3).toFixed(0) + " KB";
}

const UNITS: Record<string, number> = { B: 1, KiB: 2 ** 10, MiB: 2 ** 20, GiB: 2 ** 30, TiB: 2 ** 40 };

function parseSize(s: string): number {
  const m = s.match(/([\d.]+)\s*(B|KiB|MiB|GiB|TiB)/);
  return m ? Math.round(parseFloat(m[1]) * UNITS[m[2]]) : 0;
}

function unescapeHtml(s: string): string {
  return s
    .replace(/&#(\d+);/g, (_, n) => String.fromCodePoint(Number(n)))
    .replace(/&quot;/g, '"')
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&amp;/g, "&");
}

function magnetFromHash(hash: string, name: string): string {
  const trackers = [
    "http://nyaa.tracker.wf:7777/announce",
    "udp://tracker.opentrackr.org:1337/announce",
    "udp://open.stealth.si:80/announce",
    "udp://exodus.desync.com:6969/announce",
    "udp://tracker.torrent.eu.org:451/announce",
  ];
  const params = trackers.map(t => `&tr=${encodeURIComponent(t)}`).join("");
  return `magnet:?xt=urn:btih:${hash}&dn=${encodeURIComponent(name)}${params}`;
}

async function knaben(query: string, limit: number): Promise<Result[]> {
  const res = await vpnFetch("https://api.knaben.org/v1", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      query,
      search_field: "title",
      order_by: "seeders",
      order_direction: "desc",
      size: limit,
      hide_unsafe: true,
      hide_xxx: true,
    }),
  });
  if (!res.ok) throw new Error(`Knaben returned ${res.status}`);

  const data = await res.json() as {
    hits: Array<{
      title: string;
      seeders: number;
      peers: number;
      bytes: number;
      magnetUrl?: string;
      hash?: string;
    }>;
  };

  return data.hits
    .map(h => ({
      title: h.title,
      seeds: h.seeders ?? 0,
      peers: h.peers ?? 0,
      bytes: h.bytes ?? 0,
      size: fmtSize(h.bytes ?? 0),
      magnet: h.magnetUrl ?? (h.hash ? magnetFromHash(h.hash, h.title) : ""),
      source: "knaben",
    }))
    .filter(r => r.magnet);
}

async function torrentsCSV(query: string, limit: number): Promise<Result[]> {
  const params = new URLSearchParams({ q: query, size: String(limit) });
  const res = await vpnFetch(`https://torrents-csv.com/service/search?${params}`);
  if (!res.ok) throw new Error(`TorrentsCSV returned ${res.status}`);

  const data = await res.json() as {
    torrents: Array<{
      infohash: string;
      name: string;
      size_bytes: number;
      seeders: number;
      leechers: number;
    }>;
  };

  return data.torrents.map(t => ({
    title: t.name,
    seeds: t.seeders ?? 0,
    peers: t.leechers ?? 0,
    bytes: t.size_bytes ?? 0,
    size: fmtSize(t.size_bytes ?? 0),
    magnet: magnetFromHash(t.infohash, t.name),
    source: "torrents-csv",
  }));
}

// nyaa matches whole words, so title punctuation only hurts
function nyaaTerms(s: string): string {
  return s.replace(/['`’]/g, "").replace(/[:"!?.,()[\]]/g, " ").replace(/\s+/g, " ").trim();
}

// Nyaa is the anime index. Its RSS feed ignores sort order, so the HTML
// listing sorted by seeders is scraped instead; c=1_2 is English-translated.
async function nyaaPage(q: string, limit: number): Promise<Result[]> {
  const params = new URLSearchParams({ f: "0", c: "1_2", q, s: "seeders", o: "desc" });
  const res = await vpnFetch(`https://nyaa.si/?${params}`);
  if (!res.ok) throw new Error(`Nyaa returned ${res.status}`);

  const html = await res.text();
  const results: Result[] = [];
  for (const [, cls, row] of html.matchAll(/<tr class="(default|success|danger)">([\s\S]*?)<\/tr>/g)) {
    const title = row.match(/<a href="\/view\/\d+" title="[^"]*">([^<]*)<\/a>/)?.[1];
    const magnet = row.match(/href="(magnet:[^"]+)"/)?.[1];
    if (!title || !magnet) continue;
    // centered cells: size, date, seeders, leechers, downloads
    const cells = [...row.matchAll(/<td class="text-center"[^>]*>([^<]*)<\/td>/g)].map(m => m[1]);
    const bytes = parseSize(cells[0] ?? "");
    results.push({
      title: unescapeHtml(title),
      seeds: parseInt(cells[2] ?? "") || 0,
      peers: parseInt(cells[3] ?? "") || 0,
      bytes,
      size: fmtSize(bytes),
      magnet: unescapeHtml(magnet),
      source: "nyaa",
      trusted: cls === "success",
    });
    if (results.length >= limit) break;
  }
  return results;
}

// English anime titles are often "Name: Subtitle" while uploads carry the
// romaji name, so the part before the colon or dash is searched as well
async function nyaa(query: string, limit: number): Promise<Result[]> {
  const full = nyaaTerms(query);
  const short = nyaaTerms(query.split(/:|\s[-–—]\s/)[0]);
  const queries = short && short !== full ? [full, short] : [full];
  const pages = await Promise.all(queries.map(q => nyaaPage(q, limit)));
  return pages.flat();
}

export async function search(query: string, limit = 20): Promise<Result[]> {
  const results = await Promise.allSettled([
    knaben(query, limit),
    torrentsCSV(query, limit),
    nyaa(query, limit),
  ]);

  const all: Result[] = [];
  for (const r of results) {
    if (r.status === "fulfilled") all.push(...r.value);
  }

  // dedupe by magnet hash; nyaa's own row wins over an aggregator's copy
  // since its counts are fresher and it carries the trusted flag
  const byHash = new Map<string, Result>();
  for (const r of all) {
    const hash = r.magnet.match(/btih:([a-fA-F0-9]+)/)?.[1]?.toLowerCase();
    if (!hash) continue;
    if (!byHash.has(hash) || r.source === "nyaa") byHash.set(hash, r);
  }

  const deduped = [...byHash.values()];
  deduped.sort((a, b) => b.seeds - a.seeds);
  return deduped.slice(0, limit);
}
