import pc from "picocolors";

// key parsing

const KEY_LABELS: Record<string, string> = {
  up: "\u2191", down: "\u2193", left: "\u2190", right: "\u2192",
  enter: "\u21b5", backspace: "\u232b", tab: "\u21b9", esc: "esc",
};

function parseKey(data: Buffer): string {
  const s = data.toString();
  if (s === "\x03" || s === "\x1b") return "esc";
  if (s === "\r") return "enter";
  if (s === "\x7f") return "backspace";
  if (s === "\x1b[A") return "up";
  if (s === "\x1b[B") return "down";
  if (s === "\x1b[C") return "right";
  if (s === "\x1b[D") return "left";
  if (s === "\t") return "tab";
  return s;
}

function startRaw(handler: (key: string) => void): () => void {
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

function clear() {
  process.stdout.write("\x1b[2J\x1b[H");
}

// menu bar

export type Keys = [key: string, label: string][];

function menuBar(keys: Keys) {
  const parts = keys.map(([key, label]) => {
    const display = KEY_LABELS[key] ?? key;
    return `${pc.bold(display)} ${pc.dim(label)}`;
  });
  console.log();
  console.log("  " + parts.join("  "));
}

// full-screen TUI

export interface TuiOpts<S> {
  state: S;
  render: (state: S) => void;
  keys: Keys;
  onKey: (key: string, state: S) => void | "quit" | Promise<void | "quit">;
  poll?: { fn: (state: S) => Promise<void>; ms: number };
}

export function tui<S>(opts: TuiOpts<S>): Promise<void> {
  const { state, render, keys, onKey, poll } = opts;
  const allKeys: Keys = [...keys, ["esc", "quit"]];

  const draw = () => {
    clear();
    render(state);
    menuBar(allKeys);
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
      if (key === "esc") {
        if (interval) clearInterval(interval);
        cleanup();
        resolve();
        return;
      }
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
