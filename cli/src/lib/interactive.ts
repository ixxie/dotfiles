import pc from "picocolors";

export function truncate(s: string, n: number): string {
  return s.length > n ? s.slice(0, n - 1) + "\u2026" : s;
}

export function fmtBytes(bytes: number): string {
  if (bytes >= 1e9) return (bytes / 1e9).toFixed(1) + " GB";
  if (bytes >= 1e6) return (bytes / 1e6).toFixed(0) + " MB";
  return (bytes / 1e3).toFixed(0) + " KB";
}

export function fmtSpeed(bps: number): string {
  if (bps >= 1e6) return (bps / 1e6).toFixed(1) + " MB/s";
  if (bps >= 1e3) return (bps / 1e3).toFixed(0) + " KB/s";
  return bps + " B/s";
}

export function fmtEta(seconds: number): string {
  if (seconds < 0) return "\u221E";
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = seconds % 60;
  if (h > 0) return `${h}h${String(m).padStart(2, "0")}m`;
  if (m > 0) return `${m}m${String(s).padStart(2, "0")}s`;
  return `${s}s`;
}

export function progressBar(pct: number, width = 20): string {
  const filled = Math.round(pct * width);
  const empty = width - filled;
  const bar = pc.green("\u2588".repeat(filled)) + pc.dim("\u2591".repeat(empty));
  return `${bar} ${(pct * 100).toFixed(0)}%`;
}

export function stars(n: number): string {
  const full = Math.floor(n);
  return "\u2605".repeat(full) + "\u2606".repeat(5 - full);
}

export type KeyHandler = (key: string, raw: Buffer) => void;

export function rawMode(handler: KeyHandler): () => void {
  process.stdin.setRawMode(true);
  process.stdin.resume();
  process.stdin.setEncoding("utf8");

  const onData = (data: Buffer) => {
    const s = data.toString();
    // ctrl-c
    if (s === "\x03") {
      cleanup();
      process.exit(0);
    }
    // arrow keys come as escape sequences
    if (s === "\x1b[A") return handler("up", data);
    if (s === "\x1b[B") return handler("down", data);
    if (s === "\x1b[C") return handler("right", data);
    if (s === "\x1b[D") return handler("left", data);
    handler(s, data);
  };

  process.stdin.on("data", onData);

  const cleanup = () => {
    process.stdin.removeListener("data", onData);
    process.stdin.setRawMode(false);
    process.stdin.pause();
  };

  return cleanup;
}

export function clearScreen() {
  process.stdout.write("\x1b[2J\x1b[H");
}
