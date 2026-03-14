const PROWLARR_URL = "http://127.0.0.1:9696";
const KEY_FILE = `${process.env.HOME}/.config/yo/prowlarr-key`;

export interface Result {
  title: string;
  seeds: number;
  peers: number;
  size: string;
  magnet: string;
}

async function getApiKey(): Promise<string> {
  const env = process.env.PROWLARR_API_KEY;
  if (env) return env;

  try {
    return (await Bun.file(KEY_FILE).text()).trim();
  } catch {
    throw new Error(
      `Prowlarr API key not found. Set PROWLARR_API_KEY or put the key in ${KEY_FILE}`
    );
  }
}

function fmtSize(bytes: number): string {
  if (bytes >= 1e9) return (bytes / 1e9).toFixed(1) + " GB";
  if (bytes >= 1e6) return (bytes / 1e6).toFixed(0) + " MB";
  return (bytes / 1e3).toFixed(0) + " KB";
}

export async function search(query: string, limit = 20): Promise<Result[]> {
  const apiKey = await getApiKey();
  const params = new URLSearchParams({
    query,
    type: "search",
  });
  const url = `${PROWLARR_URL}/api/v1/search?${params}`;

  const res = await fetch(url, {
    headers: { "X-Api-Key": apiKey },
  });
  if (!res.ok) {
    throw new Error(`Prowlarr returned ${res.status}`);
  }

  const data = await res.json() as Array<{
    title: string;
    seeders: number;
    leechers: number;
    size: number;
    magnetUrl?: string;
    downloadUrl?: string;
    guid: string;
  }>;

  const results: Result[] = [];
  for (const item of data) {
    const magnet = item.magnetUrl ?? item.downloadUrl ?? "";
    if (!magnet) continue;

    results.push({
      title: item.title,
      seeds: item.seeders ?? 0,
      peers: item.leechers ?? 0,
      size: fmtSize(item.size ?? 0),
      magnet,
    });
  }

  results.sort((a, b) => b.seeds - a.seeds);
  return results.slice(0, limit);
}
