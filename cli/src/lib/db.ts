import { Database } from "bun:sqlite";
import { existsSync, mkdirSync } from "fs";
import type { OmdbItem } from "./omdb.ts";

const DB_DIR = `${process.env.HOME}/.local/share/yo`;
const DB_PATH = `${DB_DIR}/media.db`;

let _db: Database | null = null;

function ensureDir() {
  if (!existsSync(DB_DIR)) {
    mkdirSync(DB_DIR, { recursive: true });
  }
}

export function db(): Database {
  if (_db) return _db;
  ensureDir();
  _db = new Database(DB_PATH);
  _db.exec(`
    CREATE TABLE IF NOT EXISTS items (
      id INTEGER PRIMARY KEY,
      imdb_id TEXT UNIQUE NOT NULL,
      title TEXT NOT NULL,
      year TEXT,
      type TEXT,
      genre TEXT,
      director TEXT,
      actors TEXT,
      plot TEXT,
      poster TEXT,
      imdb_rating TEXT,
      runtime TEXT,
      raw_json TEXT
    );

    CREATE TABLE IF NOT EXISTS ratings (
      id INTEGER PRIMARY KEY,
      item_id INTEGER NOT NULL REFERENCES items(id),
      rating REAL NOT NULL,
      notes TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS preferences (
      id INTEGER PRIMARY KEY,
      key TEXT UNIQUE NOT NULL,
      value TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS watchlist (
      id INTEGER PRIMARY KEY,
      item_id INTEGER NOT NULL REFERENCES items(id),
      priority INTEGER DEFAULT 0,
      added_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `);
  return _db;
}

export function saveItem(data: OmdbItem): number {
  const d = db();
  d.run(`
    INSERT OR REPLACE INTO items
      (imdb_id, title, year, type, genre, director, actors, plot, poster, imdb_rating, runtime, raw_json)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `,
    [data.imdbID, data.Title, data.Year ?? null, data.Type ?? null,
     data.Genre ?? null, data.Director ?? null, data.Actors ?? null,
     data.Plot ?? null, data.Poster ?? null, data.imdbRating ?? null,
     data.Runtime ?? null, JSON.stringify(data)]
  );
  const row = d.query("SELECT id FROM items WHERE imdb_id = ?").get(data.imdbID) as { id: number };
  return row.id;
}

export function upsertRating(itemId: number, rating: number, notes?: string) {
  const d = db();
  const existing = d.query("SELECT id FROM ratings WHERE item_id = ?").get(itemId) as { id: number } | null;
  if (existing) {
    d.run("UPDATE ratings SET rating = ?, notes = ? WHERE id = ?", [rating, notes ?? null, existing.id]);
  } else {
    d.run("INSERT INTO ratings (item_id, rating, notes) VALUES (?, ?, ?)", [itemId, rating, notes ?? null]);
  }
}

export function addToWatchlist(itemId: number, priority = 0) {
  db().run(
    "INSERT OR IGNORE INTO watchlist (item_id, priority) VALUES (?, ?)",
    [itemId, priority]
  );
}

export function removeFromWatchlist(imdbId: string) {
  db().run(`
    DELETE FROM watchlist WHERE item_id IN (
      SELECT id FROM items WHERE imdb_id = ?
    )
  `, [imdbId]);
}

export interface RatedItem {
  title: string;
  year: string | null;
  type: string | null;
  genre: string | null;
  imdb_id: string;
  rating: number;
  notes: string | null;
}

export function getRatings(): RatedItem[] {
  return db().query(`
    SELECT i.title, i.year, i.type, i.genre, i.imdb_id, r.rating, r.notes
    FROM ratings r JOIN items i ON r.item_id = i.id
    ORDER BY r.rating DESC, i.title
  `).all() as RatedItem[];
}

export interface WatchlistItem {
  title: string;
  year: string | null;
  type: string | null;
  genre: string | null;
  imdb_id: string;
  priority: number;
}

export function getWatchlist(): WatchlistItem[] {
  return db().query(`
    SELECT i.title, i.year, i.type, i.genre, i.imdb_id, w.priority
    FROM watchlist w JOIN items i ON w.item_id = i.id
    LEFT JOIN ratings r ON r.item_id = i.id
    WHERE r.id IS NULL
    ORDER BY w.priority DESC, w.added_at
  `).all() as WatchlistItem[];
}

export interface Pref {
  key: string;
  value: string;
}

export function getPrefs(): Pref[] {
  return db().query("SELECT key, value FROM preferences ORDER BY key").all() as Pref[];
}

export function setPref(key: string, value: string) {
  db().run(
    "INSERT OR REPLACE INTO preferences (key, value) VALUES (?, ?)",
    [key, value]
  );
}

export function getRatingForImdb(imdbId: string): { rating: number; notes: string | null } | null {
  return db().query(`
    SELECT r.rating, r.notes
    FROM ratings r JOIN items i ON r.item_id = i.id
    WHERE i.imdb_id = ?
  `).get(imdbId) as { rating: number; notes: string | null } | null;
}
