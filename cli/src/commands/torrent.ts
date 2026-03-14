import type { Command } from "commander";
import pc from "picocolors";
import { log, error, run } from "../utils.ts";

const JACKETT_URL = "http://127.0.0.1:9117";
const API_KEY_PATH = "/var/lib/jackett/.config/Jackett/ServerConfig.json";

interface Result {
  title: string;
  seeds: number;
  peers: number;
  size: string;
  magnet: string;
}

async function getApiKey(): Promise<string> {
  try {
    const raw = await Bun.file(API_KEY_PATH).text();
    const config = JSON.parse(raw);
    return config.APIKey;
  } catch {
    error("Could not read Jackett API key");
    console.log(pc.dim(`  Ensure Jackett is running and ${API_KEY_PATH} exists`));
    process.exit(1);
  }
}

function fmtSize(bytes: number): string {
  if (bytes >= 1e9) return (bytes / 1e9).toFixed(1) + " GB";
  if (bytes >= 1e6) return (bytes / 1e6).toFixed(0) + " MB";
  return (bytes / 1e3).toFixed(0) + " KB";
}

function truncate(s: string, n: number): string {
  return s.length > n ? s.slice(0, n - 1) + "…" : s;
}

async function search(query: string): Promise<Result[]> {
  const apiKey = await getApiKey();
  const params = new URLSearchParams({
    apikey: apiKey,
    t: "search",
    q: query,
  });
  const url = `${JACKETT_URL}/api/v2.0/indexers/all/results/torznab/api?${params}`;

  const res = await fetch(url);
  if (!res.ok) {
    error(`Jackett returned ${res.status}`);
    process.exit(1);
  }

  const xml = await res.text();
  const results: Result[] = [];

  // parse torznab XML items
  const items = xml.split("<item>").slice(1);
  for (const item of items) {
    const tag = (name: string) => item.match(new RegExp(`<${name}><!\\[CDATA\\[(.+?)\\]\\]></${name}>`))?.[1]
      ?? item.match(new RegExp(`<${name}>(.+?)</${name}>`))?.[1]
      ?? "";
    const attr = (name: string) => item.match(new RegExp(`name="${name}"\\s+value="([^"]*)"`))?.[1] ?? "";

    const magnet = item.match(/url="(magnet:[^"]*)"/)?.[1]
      ?? tag("link");

    if (!magnet) continue;

    results.push({
      title: tag("title"),
      seeds: parseInt(attr("seeders") || "0"),
      peers: parseInt(attr("peers") || "0"),
      size: fmtSize(parseInt(attr("size") || tag("size") || "0")),
      magnet,
    });
  }

  results.sort((a, b) => b.seeds - a.seeds);
  return results.slice(0, 10);
}

function printTable(results: Result[]) {
  const header = `${pc.dim("#".padStart(2))}  ${pc.dim("Seeds".padStart(5))}  ${pc.dim("Peers".padStart(5))}  ${pc.dim("Size".padEnd(8))}  ${pc.dim("Title")}`;
  console.log();
  console.log(header);
  console.log(pc.dim("─".repeat(80)));

  for (let i = 0; i < results.length; i++) {
    const r = results[i];
    const num = pc.yellow(String(i + 1).padStart(2));
    const seeds = pc.green(String(r.seeds).padStart(5));
    const peers = pc.cyan(String(r.peers).padStart(5));
    const size = pc.magenta(r.size.padEnd(8));
    const title = truncate(r.title, 54);
    console.log(`${num}  ${seeds}  ${peers}  ${size}  ${title}`);
  }
  console.log();
}

async function prompt(msg: string): Promise<string> {
  process.stdout.write(pc.yellow(msg));
  for await (const line of console) {
    return line.trim();
  }
  return "";
}

export default function register(program: Command) {
  program
    .command("torrent <query...>")
    .description("Search torrents via Jackett and add to Transmission")
    .action(async (query: string[]) => {
      const q = query.join(" ");
      log("🔍", `Searching for ${pc.white(q)}...`);

      const results = await search(q);
      if (results.length === 0) {
        error("No results found");
        process.exit(1);
      }

      printTable(results);

      const input = await prompt("Pick a torrent (1-10, q to quit): ");
      if (input === "q" || input === "") process.exit(0);

      const idx = parseInt(input) - 1;
      if (isNaN(idx) || idx < 0 || idx >= results.length) {
        error("Invalid selection");
        process.exit(1);
      }

      const chosen = results[idx];
      log("📥", `Adding ${pc.white(truncate(chosen.title, 60))}...`);

      if (await run(["transmission-remote", "--add", chosen.magnet])) {
        console.log(pc.green("  Added to Transmission!"));
      } else {
        error("Failed to add torrent");
        process.exit(1);
      }
    });
}
