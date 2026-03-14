import { config } from "./config.ts";

export interface Result {
  title: string;
  seeds: number;
  peers: number;
  size: string;
  magnet: string;
}

function vpnFetch(url: string, opts?: RequestInit): Promise<Response> {
  const proxy = config().proxy;
  return fetch(url, { ...opts, ...(proxy ? { proxy } : {}) } as any);
}

function fmtSize(bytes: number): string {
  if (bytes >= 1e9) return (bytes / 1e9).toFixed(1) + " GB";
  if (bytes >= 1e6) return (bytes / 1e6).toFixed(0) + " MB";
  return (bytes / 1e3).toFixed(0) + " KB";
}

function magnetFromHash(hash: string, name: string): string {
  const trackers = [
    "udp://tracker.opentrackr.org:1337/announce",
    "udp://open.stealth.si:80/announce",
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
      size: fmtSize(h.bytes ?? 0),
      magnet: h.magnetUrl ?? (h.hash ? magnetFromHash(h.hash, h.title) : ""),
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
    size: fmtSize(t.size_bytes ?? 0),
    magnet: magnetFromHash(t.infohash, t.name),
  }));
}

export async function search(query: string, limit = 20): Promise<Result[]> {
  const results = await Promise.allSettled([
    knaben(query, limit),
    torrentsCSV(query, limit),
  ]);

  const all: Result[] = [];
  for (const r of results) {
    if (r.status === "fulfilled") all.push(...r.value);
  }

  // dedupe by magnet hash
  const seen = new Set<string>();
  const deduped = all.filter(r => {
    const hash = r.magnet.match(/btih:([a-fA-F0-9]+)/)?.[1]?.toLowerCase();
    if (!hash || seen.has(hash)) return false;
    seen.add(hash);
    return true;
  });

  deduped.sort((a, b) => b.seeds - a.seeds);
  return deduped.slice(0, limit);
}
