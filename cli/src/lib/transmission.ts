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

// status codes
export const STATUS = {
  0: "Stopped",
  1: "Check wait",
  2: "Checking",
  3: "DL wait",
  4: "Downloading",
  5: "Seed wait",
  6: "Seeding",
} as Record<number, string>;

const TORRENT_FIELDS = [
  "id", "name", "status", "percentDone",
  "rateDownload", "rateUpload", "totalSize", "eta", "uploadRatio",
];

export async function list(): Promise<Torrent[]> {
  const res = await rpc("torrent-get", { fields: TORRENT_FIELDS });
  return (res.arguments as { torrents: Torrent[] }).torrents;
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
