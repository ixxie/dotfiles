const TMDB_KEY = "76ea7d3ccb958c62daa83e6a52be057e";
const BASE = "https://api.themoviedb.org/3";

interface TmdbResult {
  id: number;
  title?: string;
  name?: string;
  release_date?: string;
  first_air_date?: string;
  media_type?: string;
}

export interface SimilarTitle {
  title: string;
  year: string;
  type: "movie" | "series";
  tmdbId: number;
}

async function get(path: string, params: Record<string, string> = {}): Promise<any> {
  params.api_key = TMDB_KEY;
  const url = `${BASE}${path}?${new URLSearchParams(params)}`;
  const res = await fetch(url);
  if (!res.ok) return null;
  return res.json();
}

export async function findByImdbId(imdbId: string): Promise<{ tmdbId: number; type: "movie" | "tv" } | null> {
  const data = await get(`/find/${imdbId}`, { external_source: "imdb_id" });
  if (!data) return null;
  if (data.movie_results?.length) {
    return { tmdbId: data.movie_results[0].id, type: "movie" };
  }
  if (data.tv_results?.length) {
    return { tmdbId: data.tv_results[0].id, type: "tv" };
  }
  return null;
}

export interface StreamingProvider {
  name: string;
  type: "stream" | "rent" | "buy";
}

export interface WatchInfo {
  providers: StreamingProvider[];
  link: string | null; // JustWatch URL
}

let _region: string | null = null;

async function detectRegion(): Promise<string> {
  if (_region) return _region;
  try {
    const res = await fetch("https://ipapi.co/country_code/");
    if (res.ok) _region = (await res.text()).trim().toUpperCase();
  } catch {}
  _region ??= "US";
  return _region;
}

export async function getProviders(imdbId: string, region?: string): Promise<WatchInfo> {
  region ??= await detectRegion();
  const found = await findByImdbId(imdbId);
  if (!found) return { providers: [], link: null };
  const data = await get(`/${found.type}/${found.tmdbId}/watch/providers`);
  if (!data?.results?.[region]) return { providers: [], link: null };
  const r = data.results[region];
  const providers: StreamingProvider[] = [];
  for (const p of r.flatrate ?? []) {
    providers.push({ name: p.provider_name, type: "stream" });
  }
  for (const p of r.rent ?? []) {
    providers.push({ name: p.provider_name, type: "rent" });
  }
  for (const p of r.buy ?? []) {
    providers.push({ name: p.provider_name, type: "buy" });
  }
  return { providers, link: r.link ?? null };
}

export async function getSimilar(tmdbId: number, type: "movie" | "tv"): Promise<SimilarTitle[]> {
  const data = await get(`/${type}/${tmdbId}/recommendations`);
  if (!data?.results) return [];
  return data.results.slice(0, 20).map((r: TmdbResult) => ({
    title: r.title ?? r.name ?? "",
    year: (r.release_date ?? r.first_air_date ?? "").slice(0, 4),
    type: type === "tv" ? "series" as const : "movie" as const,
    tmdbId: r.id,
  })).filter((t: SimilarTitle) => t.title);
}
