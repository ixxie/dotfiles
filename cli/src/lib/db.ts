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

function migrate(d: Database) {
  // ensure default profile exists
  d.run("INSERT OR IGNORE INTO profiles (id, name) VALUES (1, 'Matan')");
  // rename legacy default profile
  d.run("UPDATE profiles SET name = 'Matan' WHERE id = 1 AND name = 'default'");

  // add profile_id columns if missing (existing DBs)
  const cols = (table: string) => {
    const rows = d.query(`PRAGMA table_info(${table})`).all() as { name: string }[];
    return new Set(rows.map(r => r.name));
  };
  if (!cols("ratings").has("profile_id")) {
    d.exec("ALTER TABLE ratings ADD COLUMN profile_id INTEGER NOT NULL DEFAULT 1 REFERENCES profiles(id)");
  }
  if (!cols("watchlist").has("profile_id")) {
    d.exec("ALTER TABLE watchlist ADD COLUMN profile_id INTEGER NOT NULL DEFAULT 1 REFERENCES profiles(id)");
  }
  if (!cols("preferences").has("profile_id")) {
    d.exec("ALTER TABLE preferences ADD COLUMN profile_id INTEGER NOT NULL DEFAULT 1 REFERENCES profiles(id)");
  }
}

// profiles

export interface Profile {
  id: number;
  name: string;
}

export function getProfiles(): Profile[] {
  return db().query("SELECT id, name FROM profiles ORDER BY id").all() as Profile[];
}

export function createProfile(name: string): Profile {
  db().run("INSERT INTO profiles (name) VALUES (?)", [name]);
  return db().query("SELECT id, name FROM profiles WHERE name = ?").get(name) as Profile;
}

export function deleteProfile(id: number) {
  if (id === 1) return;
  const d = db();
  d.run("DELETE FROM ratings WHERE profile_id = ?", [id]);
  d.run("DELETE FROM watchlist WHERE profile_id = ?", [id]);
  d.run("DELETE FROM preferences WHERE profile_id = ?", [id]);
  d.run("DELETE FROM profiles WHERE id = ?", [id]);
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

    CREATE TABLE IF NOT EXISTS profiles (
      id INTEGER PRIMARY KEY,
      name TEXT UNIQUE NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS ratings (
      id INTEGER PRIMARY KEY,
      item_id INTEGER NOT NULL REFERENCES items(id),
      profile_id INTEGER NOT NULL DEFAULT 1 REFERENCES profiles(id),
      rating REAL NOT NULL,
      notes TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(item_id, profile_id)
    );

    CREATE TABLE IF NOT EXISTS preferences (
      id INTEGER PRIMARY KEY,
      profile_id INTEGER NOT NULL DEFAULT 1 REFERENCES profiles(id),
      key TEXT NOT NULL,
      value TEXT NOT NULL,
      UNIQUE(profile_id, key)
    );

    CREATE TABLE IF NOT EXISTS watchlist (
      id INTEGER PRIMARY KEY,
      item_id INTEGER NOT NULL REFERENCES items(id),
      profile_id INTEGER NOT NULL DEFAULT 1 REFERENCES profiles(id),
      priority INTEGER DEFAULT 0,
      added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(item_id, profile_id)
    );
  `);
  migrate(_db);
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

export function upsertRating(itemId: number, rating: number, profileId = 1, notes?: string) {
  const d = db();
  const existing = d.query(
    "SELECT id FROM ratings WHERE item_id = ? AND profile_id = ?"
  ).get(itemId, profileId) as { id: number } | null;
  if (existing) {
    d.run("UPDATE ratings SET rating = ?, notes = ? WHERE id = ?", [rating, notes ?? null, existing.id]);
  } else {
    d.run("INSERT INTO ratings (item_id, profile_id, rating, notes) VALUES (?, ?, ?, ?)",
      [itemId, profileId, rating, notes ?? null]);
  }
}

export function addToWatchlist(itemId: number, profileId = 1, priority = 0) {
  db().run(
    "INSERT OR IGNORE INTO watchlist (item_id, profile_id, priority) VALUES (?, ?, ?)",
    [itemId, profileId, priority]
  );
}

export function removeFromWatchlist(imdbId: string, profileId?: number) {
  if (profileId != null) {
    db().run(`
      DELETE FROM watchlist WHERE profile_id = ? AND item_id IN (
        SELECT id FROM items WHERE imdb_id = ?
      )
    `, [profileId, imdbId]);
  } else {
    db().run(`
      DELETE FROM watchlist WHERE item_id IN (
        SELECT id FROM items WHERE imdb_id = ?
      )
    `, [imdbId]);
  }
}

export interface RatedItem {
  title: string;
  year: string | null;
  type: string | null;
  genre: string | null;
  imdb_id: string;
  rating: number;
  notes: string | null;
  profile_id: number;
}

export function getRatings(profileIds?: number[]): RatedItem[] {
  if (profileIds?.length) {
    const placeholders = profileIds.map(() => "?").join(",");
    return db().query(`
      SELECT i.title, i.year, i.type, i.genre, i.imdb_id, r.rating, r.notes, r.profile_id
      FROM ratings r JOIN items i ON r.item_id = i.id
      WHERE r.profile_id IN (${placeholders})
      ORDER BY r.rating DESC, i.title
    `).all(...profileIds) as RatedItem[];
  }
  return db().query(`
    SELECT i.title, i.year, i.type, i.genre, i.imdb_id, r.rating, r.notes, r.profile_id
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
  profile_id: number;
}

export function getWatchlist(profileIds?: number[]): WatchlistItem[] {
  if (profileIds?.length) {
    const placeholders = profileIds.map(() => "?").join(",");
    return db().query(`
      SELECT i.title, i.year, i.type, i.genre, i.imdb_id, w.priority, w.profile_id
      FROM watchlist w JOIN items i ON w.item_id = i.id
      WHERE w.profile_id IN (${placeholders})
      ORDER BY w.priority DESC, w.added_at
    `).all(...profileIds) as WatchlistItem[];
  }
  return db().query(`
    SELECT i.title, i.year, i.type, i.genre, i.imdb_id, w.priority, w.profile_id
    FROM watchlist w JOIN items i ON w.item_id = i.id
    ORDER BY w.priority DESC, w.added_at
  `).all() as WatchlistItem[];
}

export interface Pref {
  key: string;
  value: string;
}

export function getPrefs(profileId = 1): Pref[] {
  return db().query(
    "SELECT key, value FROM preferences WHERE profile_id = ? ORDER BY key"
  ).all(profileId) as Pref[];
}

export function setPref(key: string, value: string, profileId = 1) {
  db().run(
    "INSERT OR REPLACE INTO preferences (profile_id, key, value) VALUES (?, ?, ?)",
    [profileId, key, value]
  );
}

export function getRatingForImdb(imdbId: string, profileIds?: number[]): { rating: number; notes: string | null; profile_id: number }[] {
  if (profileIds?.length) {
    const placeholders = profileIds.map(() => "?").join(",");
    return db().query(`
      SELECT r.rating, r.notes, r.profile_id
      FROM ratings r JOIN items i ON r.item_id = i.id
      WHERE i.imdb_id = ? AND r.profile_id IN (${placeholders})
    `).all(imdbId, ...profileIds) as { rating: number; notes: string | null; profile_id: number }[];
  }
  return db().query(`
    SELECT r.rating, r.notes, r.profile_id
    FROM ratings r JOIN items i ON r.item_id = i.id
    WHERE i.imdb_id = ?
  `).all(imdbId) as { rating: number; notes: string | null; profile_id: number }[];
}
