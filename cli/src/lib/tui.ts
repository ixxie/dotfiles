import pc from "picocolors";

// ansi helpers

export function stripAnsi(s: string): string {
  return s.replace(/\x1b\[[0-9;]*m/g, "");
}

export function visWidth(s: string): number {
  return stripAnsi(s).length;
}

export function truncVis(s: string, width: number): string {
  let vis = 0;
  let result = "";
  const re = /(\x1b\[[0-9;]*m)|(.)/g;
  let m;
  while ((m = re.exec(s)) !== null) {
    if (m[1]) {
      result += m[1];
    } else {
      if (vis >= width - 1) { result += "\u2026"; break; }
      result += m[2];
      vis++;
    }
  }
  return result;
}

export function sliceVis(s: string, start: number, width: number): string {
  let vis = 0;
  let prefix = "";
  let result = "";
  const re = /(\x1b\[[0-9;]*m)|(.)/g;
  let m;
  let taken = 0;
  while ((m = re.exec(s)) !== null) {
    if (m[1]) {
      if (vis < start) {
        prefix += m[1];
      } else {
        result += m[1];
      }
    } else {
      if (vis >= start) {
        if (taken >= width) break;
        result += m[2];
        taken++;
      }
      vis++;
    }
  }
  return prefix + result;
}

export function padTo(s: string, width: number): string {
  const vis = visWidth(s);
  if (vis >= width) return truncVis(s, width);
  return s + " ".repeat(width - vis);
}

export function wordWrap(text: string, width: number): string[] {
  const words = text.split(/\s+/);
  const lines: string[] = [];
  let line = "";
  for (const word of words) {
    if (line.length + word.length + 1 > width && line) {
      lines.push(line);
      line = word;
    } else {
      line = line ? line + " " + word : word;
    }
  }
  if (line) lines.push(line);
  return lines;
}

// key parsing

const KEY_LABELS: Record<string, string> = {
  up: "\u2191", down: "\u2193", left: "\u2190", right: "\u2192",
  enter: "\u21b5", backspace: "\u232b", tab: "\u21b9", esc: "esc",
};

function parseKey(data: Buffer): string {
  const s = data.toString();
  if (s === "\x03") { process.exit(0); }
  if (s === "\x1b") return "esc";
  if (s === "\r") return "enter";
  if (s === "\x7f") return "backspace";
  if (s === "\x1b[A") return "up";
  if (s === "\x1b[B") return "down";
  if (s === "\x1b[C") return "right";
  if (s === "\x1b[D") return "left";
  if (s === "\t") return "tab";
  return s;
}

export function startRaw(handler: (key: string) => void): () => void {
  process.stdin.setRawMode(true);
  process.stdin.resume();
  process.stdin.setEncoding("utf8");

  const onData = (data: Buffer) => handler(parseKey(data));
  process.stdin.on("data", onData);

  return () => {
    process.stdin.removeListener("data", onData);
    process.stdin.setRawMode(false);
    process.stdin.pause();
  };
}

let _buf: string[] | null = null;
const _origWrite = process.stdout.write.bind(process.stdout);
const _origLog = console.log.bind(console);

export function clear() {
  _buf = [];
  // redirect console.log to buffer
  console.log = (...args: any[]) => {
    const line = args.map(a => typeof a === "string" ? a : String(a)).join(" ");
    _buf!.push(line);
  };
}

export function flush() {
  const rows = process.stdout.rows ?? 24;
  const frame = (_buf ?? []).slice(0, rows);
  _buf = null;
  console.log = _origLog;
  // build frame: hide cursor, home, content with per-line clear, clear below, show cursor
  const out = "\x1b[?25l\x1b[H" +
    frame.map(l => l + "\x1b[K").join("\n") +
    "\x1b[J\x1b[?25h";
  _origWrite(out);
}

// layout

export type Keys = [key: string, label: string][];

export function menuBar(keys: Keys) {
  const parts = keys.map(([key, label]) => {
    const display = KEY_LABELS[key] ?? key;
    return label ? `${pc.bold(display)} ${pc.dim(label)}` : pc.bold(display);
  });
  console.log();
  console.log("  " + parts.join("  "));
}

export function renderSplit(leftLines: string[], rightLines: string[], leftWidth: number) {
  const max = Math.max(leftLines.length, rightLines.length);
  const sep = pc.dim("\u2502");
  const reset = "\x1b[0m";
  for (let i = 0; i < max; i++) {
    const left = padTo(leftLines[i] ?? "", leftWidth);
    const right = rightLines[i] ?? "";
    console.log(`${left}${reset} ${sep} ${right}${reset}`);
  }
}

export function tabBar(tabs: string[], active: number): string {
  return "  " + tabs.map((t, i) =>
    i === active ? pc.bold(pc.cyan(t)) : t
  ).join("  \u2502  ");
}

// full-screen TUI

export interface TuiOpts<S> {
  state: S;
  render: (state: S) => void;
  keys: Keys | ((state: S) => Keys);
  onKey: (key: string, state: S) => void | "quit" | Promise<void | "quit">;
  poll?: { fn: (state: S) => Promise<void>; ms: number };
}

export function tui<S>(opts: TuiOpts<S>): Promise<void> {
  const { state, render, keys, onKey, poll } = opts;

  const draw = () => {
    clear();
    render(state);
    const k = typeof keys === "function" ? keys(state) : keys;
    menuBar(k);
    flush();
  };
  draw();

  let interval: ReturnType<typeof setInterval> | null = null;
  if (poll) {
    interval = setInterval(async () => {
      await poll.fn(state);
      draw();
    }, poll.ms);
  }

  return new Promise<void>((resolve) => {
    const cleanup = startRaw(async (key) => {
      const result = await onKey(key, state);
      if (result === "quit") {
        if (interval) clearInterval(interval);
        cleanup();
        resolve();
        return;
      }
      draw();
    });
  });
}

// dialog (modal overlay for use inside a TUI loop)

export interface DialogItem<T> {
  name: string;
  value: T;
}

export interface Dialog<T> {
  title: string;
  items: DialogItem<T>[];
  cursor: number;
  selected: Set<number>;
  multi: boolean;
  resolve: (result: T[] | null) => void;
}

export function dialogKeys(multi: boolean): Keys {
  if (multi) {
    return [["up", ""], ["down", ""], [" ", "toggle"], ["enter", "confirm"], ["esc", "cancel"]];
  }
  return [["up", ""], ["down", ""], ["enter", "select"], ["esc", "cancel"]];
}

export function handleDialogKey<T>(key: string, dialog: Dialog<T>): "done" | void {
  if (key === "esc") {
    dialog.resolve(null);
    return "done";
  }
  if (key === "enter") {
    if (dialog.multi) {
      const result = [...dialog.selected].sort().map(i => dialog.items[i].value);
      dialog.resolve(result.length ? result : null);
    } else {
      dialog.resolve([dialog.items[dialog.cursor].value]);
    }
    return "done";
  }
  if (key === "up" && dialog.cursor > 0) {
    dialog.cursor--;
  } else if (key === "down" && dialog.cursor < dialog.items.length - 1) {
    dialog.cursor++;
  } else if (key === " " && dialog.multi) {
    if (dialog.selected.has(dialog.cursor)) {
      dialog.selected.delete(dialog.cursor);
    } else {
      dialog.selected.add(dialog.cursor);
    }
  }
}

export function dialogLines<T>(dialog: Dialog<T>, width: number): string[] {
  const lines: string[] = [];
  const innerW = width - 4;
  const top = "\u250c\u2500 " + truncVis(dialog.title, innerW - 2) + " " +
    "\u2500".repeat(Math.max(0, innerW - visWidth(dialog.title) - 2)) + "\u2510";
  lines.push(top);

  for (let i = 0; i < dialog.items.length; i++) {
    const arrow = i === dialog.cursor ? pc.yellow("\u25B6") : " ";
    let check = "";
    if (dialog.multi) {
      check = dialog.selected.has(i) ? pc.green("\u25C9") + " " : pc.dim("\u25CB") + " ";
    }
    const name = truncVis(dialog.items[i].name, innerW - (dialog.multi ? 6 : 4));
    lines.push(`\u2502 ${arrow} ${check}${name}${" ".repeat(Math.max(0, innerW - visWidth(`${arrow} ${check}${name}`) + 2))}\u2502`);
  }

  lines.push("\u2502" + " ".repeat(innerW + 2) + "\u2502");
  const hint = dialog.multi
    ? `${pc.dim("space")} toggle  ${pc.dim("\u21b5")} confirm  ${pc.dim("esc")} cancel`
    : `${pc.dim("\u21b5")} select  ${pc.dim("esc")} cancel`;
  lines.push(`\u2502 ${hint}${" ".repeat(Math.max(0, innerW - visWidth(hint)))} \u2502`);
  lines.push("\u2514" + "\u2500".repeat(innerW + 2) + "\u2518");

  return lines;
}

// prompts

export function input(opts: {
  message: string;
  default?: string;
}): Promise<string | null> {
  let buf = opts.default ?? "";

  const draw = () => {
    clear();
    console.log(`  ${pc.bold(opts.message)}\n`);
    console.log(`  ${buf}\u2588`);
    menuBar([["enter", "confirm"], ["esc", "cancel"]]);
    flush();
  };
  draw();

  return new Promise((resolve) => {
    const cleanup = startRaw((key) => {
      if (key === "esc") { cleanup(); resolve(null); }
      else if (key === "enter") { cleanup(); resolve(buf); }
      else if (key === "backspace") { buf = buf.slice(0, -1); draw(); }
      else if (key.length === 1 && key >= " ") { buf += key; draw(); }
    });
  });
}

export function select<T>(opts: {
  message: string;
  items: { name: string; value: T }[];
  pageSize?: number;
}): Promise<T | null> {
  const { items, pageSize = 15 } = opts;
  let cursor = 0;
  let offset = 0;

  const draw = () => {
    clear();
    console.log(`  ${pc.bold(opts.message)}\n`);
    const end = Math.min(offset + pageSize, items.length);
    for (let i = offset; i < end; i++) {
      const prefix = i === cursor ? pc.yellow("\u25B6 ") : "  ";
      console.log(`${prefix}${items[i].name}`);
    }
    if (items.length > pageSize) {
      console.log(pc.dim(`\n  ${cursor + 1}/${items.length}`));
    }
    menuBar([["up", "up"], ["down", "down"], ["enter", "select"], ["esc", "cancel"]]);
    flush();
  };
  draw();

  return new Promise((resolve) => {
    const cleanup = startRaw((key) => {
      if (key === "esc") { cleanup(); resolve(null); }
      else if (key === "enter") { cleanup(); resolve(items[cursor].value); }
      else if (key === "up" && cursor > 0) {
        cursor--;
        if (cursor < offset) offset = cursor;
        draw();
      } else if (key === "down" && cursor < items.length - 1) {
        cursor++;
        if (cursor >= offset + pageSize) offset = cursor - pageSize + 1;
        draw();
      }
    });
  });
}

export function search<T>(opts: {
  message: string;
  source: (term: string) => { name: string; value: T }[];
  pageSize?: number;
}): Promise<T | null> {
  const { source, pageSize = 15 } = opts;
  let query = "";
  let cursor = 0;
  let offset = 0;
  let items = source("");

  const draw = () => {
    clear();
    console.log(`  ${pc.bold(opts.message)}\n`);
    console.log(`  ${pc.cyan("/")} ${query}\u2588\n`);
    const end = Math.min(offset + pageSize, items.length);
    if (items.length === 0) {
      console.log(pc.dim("  No matches"));
    } else {
      for (let i = offset; i < end; i++) {
        const prefix = i === cursor ? pc.yellow("\u25B6 ") : "  ";
        console.log(`${prefix}${items[i].name}`);
      }
      if (items.length > pageSize) {
        console.log(pc.dim(`\n  ${cursor + 1}/${items.length}`));
      }
    }
    menuBar([["up", "up"], ["down", "down"], ["enter", "select"], ["esc", "cancel"]]);
    flush();
  };
  draw();

  return new Promise((resolve) => {
    const cleanup = startRaw((key) => {
      if (key === "esc") { cleanup(); resolve(null); }
      else if (key === "enter" && items.length > 0) { cleanup(); resolve(items[cursor].value); }
      else if (key === "up" && cursor > 0) {
        cursor--;
        if (cursor < offset) offset = cursor;
        draw();
      } else if (key === "down" && cursor < items.length - 1) {
        cursor++;
        if (cursor >= offset + pageSize) offset = cursor - pageSize + 1;
        draw();
      } else if (key === "backspace") {
        query = query.slice(0, -1);
        items = source(query);
        cursor = 0; offset = 0;
        draw();
      } else if (key.length === 1 && key >= " ") {
        query += key;
        items = source(query);
        cursor = 0; offset = 0;
        draw();
      }
    });
  });
}
