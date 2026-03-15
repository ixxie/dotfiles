const OMDB_KEY = "b871680a";
const OMDB_URL = "https://www.omdbapi.com/";

export interface OmdbItem {
  imdbID: string;
  Title: string;
  Year?: string;
  Type?: string;
  Genre?: string;
  Director?: string;
  Actors?: string;
  Plot?: string;
  Poster?: string;
  imdbRating?: string;
  Runtime?: string;
  [key: string]: unknown;
}

export interface SearchResult {
  Title: string;
  Year: string;
  imdbID: string;
  Type: string;
  Poster: string;
}

export async function searchOmdb(query: string, type?: string, year?: string): Promise<SearchResult[]> {
  const params: Record<string, string> = { apikey: OMDB_KEY, s: query };
  if (type) params.type = type;
  if (year) params.y = year.replace(/\D.*/, "");

  const res = await fetch(`${OMDB_URL}?${new URLSearchParams(params)}`);
  const data = await res.json() as { Response: string; Search?: SearchResult[] };
  if (data.Response === "False") return [];
  return data.Search ?? [];
}

export async function getById(imdbId: string): Promise<OmdbItem | null> {
  const params = new URLSearchParams({ apikey: OMDB_KEY, i: imdbId, plot: "full" });
  const res = await fetch(`${OMDB_URL}?${params}`);
  const data = await res.json() as OmdbItem & { Response: string };
  if (data.Response === "False") return null;
  return data;
}

export async function resolve(query: string, type?: string, year?: string): Promise<SearchResult[]> {
  return searchOmdb(query, type, year);
}
