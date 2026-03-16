import pc from "picocolors";
import stringWidth from "string-width";

// ansi helpers

export function stripAnsi(s: string): string {
  return s.replace(/\x1b\[[0-9;]*m/g, "");
}

const _widthCache = new Map<string, number>();
const _segmenter = new Intl.Segmenter();

export function visWidth(s: string): number {
  const plain = stripAnsi(s);
  // fast path: pure ASCII/latin1 — no wide chars possible
  let allLatin = true;
  for (let i = 0; i < plain.length; i++) {
    if (plain.charCodeAt(i) > 0xFF) { allLatin = false; break; }
  }
  if (allLatin) return plain.length;
  // slow path: sum per-grapheme widths (cached individually)
  let w = 0;
  for (const { segment } of _segmenter.segment(plain)) {
    w += charWidth(segment);
  }
  return w;
}

function charWidth(ch: string): number {
  if (ch.length === 1 && ch.charCodeAt(0) <= 0xFF) return 1;
  const cached = _widthCache.get(ch);
  if (cached !== undefined) return cached;
  const w = stringWidth(ch);
  _widthCache.set(ch, w);
  return w;
}

// yield ANSI escapes and grapheme clusters from a styled string
function* styledGraphemes(s: string): Generator<{ ansi: true; text: string } | { ansi: false; text: string }> {
  const parts = s.split(/(\x1b\[[0-9;]*m)/);
  for (const part of parts) {
    if (!part) continue;
    if (part.startsWith("\x1b[")) {
      yield { ansi: true, text: part };
    } else {
      for (const { segment } of _segmenter.segment(part)) {
        yield { ansi: false, text: segment };
      }
    }
  }
}

export function truncVis(s: string, width: number): string {
  if (visWidth(s) <= width) return s;
  let vis = 0;
  let result = "";
  for (const seg of styledGraphemes(s)) {
    if (seg.ansi) {
      result += seg.text;
    } else {
      const cw = charWidth(seg.text);
      if (vis + cw > width - 1) { result += "\u2026"; break; }
      result += seg.text;
      vis += cw;
    }
  }
  return result;
}

export function sliceVis(s: string, start: number, width: number): string {
  let vis = 0;
  let prefix = "";
  let result = "";
  let taken = 0;
  for (const seg of styledGraphemes(s)) {
    if (seg.ansi) {
      if (vis < start) {
        prefix += seg.text;
      } else {
        result += seg.text;
      }
    } else {
      const cw = charWidth(seg.text);
      if (vis >= start) {
        if (taken + cw > width) break;
        result += seg.text;
        taken += cw;
      }
      vis += cw;
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
  if (s === "\x1b[1;5A") return "ctrl-up";
  if (s === "\x1b[1;5B") return "ctrl-down";
  if (s === "\x1b[1;5C") return "ctrl-right";
  if (s === "\x1b[1;5D") return "ctrl-left";
  if (s === "\x1bOP") return "f1";
  if (s === "\x1bOQ") return "f2";
  if (s === "\x1bOR") return "f3";
  if (s === "\x1bOS") return "f4";
  if (s === "\x1b[15~") return "f5";
  if (s === "\x1b[17~") return "f6";
  if (s === "\x1b[18~") return "f7";
  if (s === "\x1b[19~") return "f8";
  if (s === "\x1b[20~") return "f9";
  if (s === "\x1b[21~") return "f10";
  if (s === "\x1b[23~") return "f11";
  if (s === "\x1b[24~") return "f12";
  if (s === "\t") return "tab";
  if (s === "\x1b[Z") return "shift-tab";
  return s;
}

let _activeHandler: ((data: Buffer) => void) | null = null;

export function startRaw(handler: (key: string) => void): () => void {
  const prev = _activeHandler;
  if (prev) {
    process.stdin.removeListener("data", prev);
  }

  process.stdin.setRawMode(true);
  process.stdin.resume();
  process.stdin.setEncoding("utf8");

  const onData = (data: Buffer) => handler(parseKey(data));
  _activeHandler = onData;
  process.stdin.on("data", onData);

  return () => {
    process.stdin.removeListener("data", onData);
    if (prev) {
      _activeHandler = prev;
      process.stdin.on("data", prev);
    } else {
      _activeHandler = null;
      process.stdin.setRawMode(false);
      process.stdin.pause();
      _origWrite("\x1b[?25h");
    }
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

export function flush(showCursor = false) {
  const rows = process.stdout.rows ?? 24;
  const lines = (_buf ?? []).flatMap(l => l.split("\n"));
  const frame = lines.slice(0, rows);
  _buf = null;
  console.log = _origLog;
  const cursor = showCursor ? "\x1b[?25h" : "";
  const out = "\x1b[?25l\x1b[H" +
    frame.map(l => l + "\x1b[K").join("\n") +
    "\x1b[J" + cursor;
  _origWrite(out);
}

// layout

export type Keys = [key: string, label: string][];

export function menuBar(keys: Keys) {
  const fmt = ([key, label]: [string, string]) => {
    const display = KEY_LABELS[key] ?? key;
    return label ? `${pc.bold(display)} ${pc.dim(label)}` : pc.bold(display);
  };

  const arrows = keys.filter(([k]) => k === "up" || k === "down" || k === "left" || k === "right");
  const quit = keys.filter(([, l]) => l === "quit");
  const mid = keys.filter(([k, l]) => !["up", "down", "left", "right"].includes(k) && l !== "quit");

  const leftStr = arrows.map(fmt).join(" ");
  const midStr = mid.map(fmt).join("  ");
  const rightStr = quit.map(fmt).join("  ");

  const cols = (process.stdout.columns ?? 100) - 1;
  const leftVis = visWidth(leftStr);
  const midVis = visWidth(midStr);
  const rightVis = visWidth(rightStr);

  const usable = cols - 2 - leftVis - midVis - rightVis;
  const idealMidPad = Math.floor((cols - midVis) / 2) - leftVis - 2;
  const midPad = Math.max(1, Math.min(idealMidPad, usable - 1));
  const rightPad = Math.max(0, usable - midPad);

  console.log(`  ${leftStr}${" ".repeat(midPad)}${midStr}${" ".repeat(rightPad)}${rightStr}`);
}


export interface TabDef {
  key: string;
  label: string;
}

export function tabBar(tabs: TabDef[], active: number): string {
  return tabs.map((t, i) => {
    const k = i === active ? pc.bold(t.key) : pc.dim(t.key);
    const label = i === active ? pc.bold(pc.cyan(t.label)) : pc.dim(t.label);
    return `${k} ${label}`;
  }).join("   ");
}

// scroll + split-pane framework

export type Dir = "up" | "down" | "left" | "right";

export interface Scroll {
  v: number;
  h: number;
  edge: Dir | null;
}

export function mkScroll(): Scroll {
  return { v: 0, h: 0, edge: null };
}

export function parseDir(key: string): { dir: Dir; force: boolean } | null {
  if (key === "up" || key === "down" || key === "left" || key === "right") {
    return { dir: key, force: false };
  }
  const m = key.match(/^ctrl-(up|down|left|right)$/);
  if (m) {
    return { dir: m[1] as Dir, force: true };
  }
  return null;
}

export function edgeBump(scroll: Scroll, dir: Dir, atLimit: boolean, force: boolean): Dir | null {
  if (!atLimit) {
    scroll.edge = null;
    return null;
  }
  if (force || scroll.edge === dir) {
    scroll.edge = null;
    return dir;
  }
  scroll.edge = dir;
  return null;
}

const CURSOR_CHAR = "\u25B6";

export function scrollToCursor(
  lines: string[], scroll: Scroll, viewH: number, margin = 2,
) {
  const cursor = lines.findIndex(l => l.includes(CURSOR_CHAR));
  if (lines.length <= viewH) {
    scroll.v = 0;
  } else if (cursor >= 0) {
    if (cursor < scroll.v + margin) {
      scroll.v = Math.max(0, cursor - margin);
    } else if (cursor >= scroll.v + viewH - margin) {
      scroll.v = Math.min(lines.length - viewH, cursor - viewH + margin + 1);
    }
  }
}

export function viewSlice(
  lines: string[], scroll: Scroll, viewH: number, viewW?: number,
): string[] {
  const sliced = lines.slice(scroll.v, scroll.v + viewH);
  const out = viewW && scroll.h > 0
    ? sliced.map(l => sliceVis(l, scroll.h, viewW))
    : sliced;
  while (out.length < viewH) out.push("");
  return out;
}


// panel system

export interface PanelDef {
  lines: string[];
  scroll: Scroll;
  focused: boolean;
  cursor?: boolean;
}

export function columnWidths(weights: number[]): number[] {
  const cols = (process.stdout.columns ?? 100) - 1;
  const n = weights.length;
  // each panel: 2-char left edge + 2-char right edge; 1-char gap between panels
  const overhead = 4 * n + (n - 1);
  const available = Math.max(0, cols - overhead);
  const total = weights.reduce((a, b) => a + b, 0);
  return weights.map(w => Math.max(4, Math.floor(available * w / total)));
}

const DIM_BOX = {
  tl: pc.dim("\u250c"), tr: pc.dim("\u2510"),
  bl: pc.dim("\u2514"), br: pc.dim("\u2518"),
  h: pc.dim("\u2500"), v: pc.dim("\u2502"),
};

export function renderColumns(panels: PanelDef[], widths: number[], viewH: number) {
  const innerH = viewH - 3; // header + top padding + bottom padding
  const n = panels.length;

  // scroll and slice
  const slices: string[][] = [];
  for (let i = 0; i < n; i++) {
    const p = panels[i];
    const maxV = Math.max(0, p.lines.length - innerH);
    p.scroll.v = Math.min(p.scroll.v, maxV);
    if (p.cursor) {
      scrollToCursor(p.lines, p.scroll, innerH);
    }
    slices.push(viewSlice(p.lines, p.scroll, innerH, widths[i]));
  }

  // header row
  const headers: string[] = [];
  for (let i = 0; i < n; i++) {
    if (panels[i].focused) {
      headers.push(DIM_BOX.tl + DIM_BOX.h.repeat(widths[i] + 2) + DIM_BOX.tr);
    } else {
      headers.push(" ".repeat(widths[i] + 4));
    }
  }
  console.log(headers.join(" "));

  // row helpers
  const contentRow = (row: number) => {
    const cells: string[] = [];
    for (let i = 0; i < n; i++) {
      const content = padTo(slices[i][row] ?? "", widths[i]);
      if (panels[i].focused) {
        cells.push(DIM_BOX.v + " " + content + " " + DIM_BOX.v);
      } else {
        cells.push("  " + content + "  ");
      }
    }
    console.log(cells.join(" "));
  };

  // top padding
  contentRow(-1);

  // content rows
  for (let row = 0; row < innerH; row++) {
    contentRow(row);
  }

  // bottom row
  const bottomCells: string[] = [];
  for (let i = 0; i < n; i++) {
    if (panels[i].focused) {
      bottomCells.push(DIM_BOX.bl + DIM_BOX.h.repeat(widths[i] + 2) + DIM_BOX.br);
    } else {
      bottomCells.push(" ".repeat(widths[i] + 4));
    }
  }
  console.log(bottomCells.join(" "));
}

// panel navigation

export type PanelNav =
  | { kind: "cursor"; pos: number; count: number; drill?: boolean }
  | { kind: "scroll"; count: number; hScroll?: boolean };

export type ColumnsAction =
  | { type: "focus"; index: number }
  | { type: "select" }
  | { type: "back" }
  | { type: "cursor"; prev: number }
  | { type: "scroll" }
  | { type: "none" };

export function columnsNav(
  key: string,
  panels: { scroll: Scroll; nav: PanelNav }[],
  focused: number,
): ColumnsAction | null {
  const parsed = parseDir(key);
  if (!parsed) {
    panels[focused].scroll.edge = null;
    return null;
  }

  const { dir, force } = parsed;
  const p = panels[focused];

  if (p.nav.kind === "cursor") {
    if (dir === "up") {
      if (p.nav.pos > 0) {
        const prev = p.nav.pos;
        p.nav.pos--;
        return { type: "cursor", prev };
      }
      return { type: "none" };
    }
    if (dir === "down") {
      if (p.nav.pos < p.nav.count - 1) {
        const prev = p.nav.pos;
        p.nav.pos++;
        return { type: "cursor", prev };
      }
      return { type: "none" };
    }
    if (dir === "right") {
      if (p.nav.drill) return { type: "select" };
      if (focused < panels.length - 1) return { type: "focus", index: focused + 1 };
      return { type: "none" };
    }
    if (dir === "left") {
      if (p.nav.drill || focused === 0) return { type: "back" };
      return { type: "focus", index: focused - 1 };
    }
    return { type: "none" };
  }

  if (p.nav.kind === "scroll") {
    if (dir === "up") {
      if (p.scroll.v > 0) {
        p.scroll.v--;
        p.scroll.edge = null;
        return { type: "scroll" };
      }
      return { type: "none" };
    }
    if (dir === "down") {
      if (p.scroll.v < p.nav.count - 1) {
        p.scroll.v++;
        p.scroll.edge = null;
        return { type: "scroll" };
      }
      return { type: "none" };
    }
    if (dir === "left") {
      if (p.nav.hScroll && p.scroll.h > 0) {
        p.scroll.h = Math.max(0, p.scroll.h - 8);
        p.scroll.edge = null;
        return { type: "scroll" };
      }
      // hScroll panels: keep double-tap when at h=0
      if (p.nav.hScroll) {
        if (focused > 0 && edgeBump(p.scroll, "left", true, force)) {
          return { type: "focus", index: focused - 1 };
        }
        return { type: "none" };
      }
      // non-hScroll scroll panels: immediate crossing
      if (focused > 0) {
        return { type: "focus", index: focused - 1 };
      }
      return { type: "back" };
    }
    if (dir === "right") {
      if (p.nav.hScroll) {
        p.scroll.h += 8;
        p.scroll.edge = null;
        return { type: "scroll" };
      }
      // non-hScroll scroll panels: immediate crossing
      if (focused < panels.length - 1) {
        return { type: "focus", index: focused + 1 };
      }
      return { type: "none" };
    }
  }

  return null;
}

// bars

export function statusBar(status: string) {
  console.log(status ? `  ${pc.dim(status)}` : "");
}

// app shell

export interface AppShellOpts {
  tabs: TabDef[];
  activeTab: number;
  tabLeft?: string;
  tabRight?: string;
  toolbar?: string[];
  panels: PanelDef[];
  widths: number[];
  status: string;
  keys: Keys;
}

export function appShell(opts: AppShellOpts): void {
  clear();
  const cols = (process.stdout.columns ?? 100) - 1;
  const rows = process.stdout.rows ?? 24;

  // tab bar (centered, with optional flanking labels)
  const tabs = tabBar(opts.tabs, opts.activeTab);
  const tabVis = visWidth(tabs);
  if (opts.tabLeft || opts.tabRight) {
    const leftStr = opts.tabLeft ?? "";
    const rightStr = opts.tabRight ?? "";
    const leftVis = visWidth(leftStr);
    const rightVis = visWidth(rightStr);
    const tabPad = Math.max(0, Math.floor((cols - tabVis) / 2));
    const rightPad = Math.max(0, cols - tabPad - tabVis - rightVis - 1);
    console.log(`${leftStr}${" ".repeat(Math.max(0, tabPad - leftVis))}${tabs}${" ".repeat(rightPad)}${rightStr}`);
  } else {
    const tabPad = Math.max(0, Math.floor((cols - tabVis) / 2));
    console.log(`${" ".repeat(tabPad)}${tabs}`);
  }

  // toolbar rows
  const toolbarH = opts.toolbar?.length ?? 0;
  if (opts.toolbar) {
    for (const row of opts.toolbar) console.log(row);
  }

  // spacer
  console.log();

  // panels
  const used = 1 + toolbarH + 1 + 2; // tab + toolbar + spacer + status + menu
  const viewH = Math.max(5, rows - used);
  renderColumns(opts.panels, opts.widths, viewH);

  // status + menu (auto-append q quit)
  statusBar(opts.status);
  const keys: Keys = [...opts.keys, ["q", "quit"]];
  menuBar(keys);
  flush();
}

// standard key handling

export function handleStdKey(
  key: string,
  tabCount: number,
  activeTab: number,
  shortcuts: Record<string, number>,
  canSwitch: boolean,
): { action: "quit" } | { action: "tab"; index: number } | null {
  if (key === "q") return { action: "quit" };
  if (!canSwitch) return null;
  if (key === "tab" || key === " ") {
    return { action: "tab", index: (activeTab + 1) % tabCount };
  }
  if (key === "shift-tab") {
    return { action: "tab", index: (activeTab - 1 + tabCount) % tabCount };
  }
  if (key in shortcuts && shortcuts[key] !== activeTab) {
    return { action: "tab", index: shortcuts[key] };
  }
  return null;
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
