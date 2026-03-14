const RPC_URL = "http://127.0.0.1:9091/transmission/rpc";

let sessionId = "";

interface RpcResponse {
  result: string;
  arguments?: Record<string, unknown>;
}

async function rpc(method: string, args?: Record<string, unknown>): Promise<RpcResponse> {
  const body = JSON.stringify({ method, arguments: args });

  const doFetch = () => fetch(RPC_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-Transmission-Session-Id": sessionId,
    },
    body,
  });

  let res = await doFetch();
  if (res.status === 409) {
    sessionId = res.headers.get("X-Transmission-Session-Id") ?? "";
    res = await doFetch();
  }

  if (!res.ok) {
    throw new Error(`Transmission RPC ${res.status}: ${await res.text()}`);
  }
  return res.json();
}

export interface Torrent {
  id: number;
  name: string;
  status: number;
  percentDone: number;
  rateDownload: number;
  rateUpload: number;
  totalSize: number;
  eta: number;
  uploadRatio: number;
}

export interface TorrentFile {
  name: string;
  length: number;
  bytesCompleted: number;
}

export interface TorrentFileStat {
  wanted: boolean;
  priority: number; // -1 low, 0 normal, 1 high
}

export interface TorrentDetail extends Torrent {
  downloadDir: string;
  files: TorrentFile[];
  fileStats: TorrentFileStat[];
}

export const STATUS = {
  0: "Stopped",
  1: "Check wait",
  2: "Checking",
  3: "DL wait",
  4: "Downloading",
  5: "Seed wait",
  6: "Seeding",
} as Record<number, string>;

export const PRIORITY = {
  [-1]: "LOW",
  [0]: "NORM",
  [1]: "HIGH",
} as Record<number, string>;

const TORRENT_FIELDS = [
  "id", "name", "status", "percentDone",
  "rateDownload", "rateUpload", "totalSize", "eta", "uploadRatio",
];

const DETAIL_FIELDS = [
  ...TORRENT_FIELDS, "downloadDir", "files", "fileStats",
];

export async function list(): Promise<Torrent[]> {
  const res = await rpc("torrent-get", { fields: TORRENT_FIELDS });
  return (res.arguments as { torrents: Torrent[] }).torrents;
}

export async function getDetail(id: number): Promise<TorrentDetail | null> {
  const res = await rpc("torrent-get", { ids: [id], fields: DETAIL_FIELDS });
  const torrents = (res.arguments as { torrents: TorrentDetail[] }).torrents;
  return torrents[0] ?? null;
}

export async function add(magnet: string) {
  return rpc("torrent-add", { filename: magnet });
}

export async function pause(ids: number[]) {
  return rpc("torrent-stop", { ids });
}

export async function resume(ids: number[]) {
  return rpc("torrent-start", { ids });
}

export async function remove(ids: number[], deleteLocal = false) {
  return rpc("torrent-remove", { ids, "delete-local-data": deleteLocal });
}

export async function setFilesWanted(id: number, wanted: number[], unwanted: number[]) {
  const args: Record<string, unknown> = { ids: [id] };
  if (wanted.length) args["files-wanted"] = wanted;
  if (unwanted.length) args["files-unwanted"] = unwanted;
  return rpc("torrent-set", args);
}

export async function setFilePriority(id: number, indices: number[], priority: "high" | "normal" | "low") {
  return rpc("torrent-set", {
    ids: [id],
    [`priority-${priority}`]: indices,
  });
}
