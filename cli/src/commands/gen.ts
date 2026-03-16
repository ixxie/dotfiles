import type { Command } from "commander";
import pc from "picocolors";
import {
  input, search, startRaw,
  truncVis, visWidth, mkScroll,
  columnWidths, columnsNav, appShell, handleStdKey,
  type Keys, type Scroll, type PanelDef,
} from "../lib/tui.ts";
import { readFile, writeFile, mkdir } from "node:fs/promises";
import { existsSync } from "node:fs";
import { join } from "node:path";
import { DOTFILES, FLAKE, sym, log, success, error, run } from "../utils.ts";
import { truncate } from "../lib/interactive.ts";

const GC_KEEP_DAYS = "7d";
const PROFILE = "/nix/var/nix/profiles/system";
const DATA_DIR = `${process.env.HOME}/.local/share/yo`;
const DIFF_DIR = `${DATA_DIR}/gen-diffs`;
const BUILD_DIR = `${DATA_DIR}/builds`;

interface Gen {
  id: string;
  date: string;
  label: string;
  current: boolean;
}

async function listGens(): Promise<Gen[]> {
  const proc = Bun.spawn(
    ["sudo", "nixos-rebuild", "list-generations", "--flake", FLAKE],
    { stdout: "pipe", stderr: "pipe" },
  );
  const out = (await new Response(proc.stdout).text()).trim();
  if (!out) return [];
  const lines = out.split("\n").slice(1); // skip header
  return lines.map((line) => {
    const current = line.includes("True");
    const parts = line.trim().split(/\s{2,}/);
    return {
      id: parts[0],
      date: parts[1],
      label: parts[2] ?? "",
      current,
    };
  });
}

async function stdout(cmd: string[], opts?: { cwd?: string }): Promise<string> {
  const proc = Bun.spawn(cmd, { stdout: "pipe", stderr: "pipe", cwd: opts?.cwd });
  const out = (await new Response(proc.stdout).text()).trim();
  const code = await proc.exited;
  return code === 0 ? out : "";
}

function sanitizeLabel(s: string): string {
  return s.replace(/[^a-zA-Z0-9.-]/g, "-").replace(/-+/g, "-").replace(/^-|-$/g, "").toLowerCase().slice(0, 80);
}

interface CommitPlan {
  files: string[];
  message: string;
}

async function generateCommitPlan(): Promise<CommitPlan[] | null> {
  try {
    log(sym.gear, pc.dim("Analyzing changes..."));
    const diff = await stdout(["git", "diff", "--cached"], { cwd: DOTFILES });
    const stat = await stdout(["git", "diff", "--cached", "--stat"], { cwd: DOTFILES });
    if (!diff) return null;

    const prompt = `You are analyzing changes to a NixOS dotfiles repo. Create a commit plan using conventional commits (feat:, fix:, refactor:, chore:, docs:, style:, etc.).

Rules:
- Split into multiple atomic commits if the changes are logically independent
- Each commit message: conventional commit subject line (max 72 chars), then a blank line, then a body with 1-3 short paragraphs explaining the why/what
- Ignore flake.lock / flake input updates unless they are the only change
- Group related file changes into one commit
- Reply with ONLY a raw JSON array, no markdown fences

Format: [{"files":["path/to/file",...],"message":"type: subject\\n\\nbody"},...]

Stat:
${stat}

Diff:
${diff}`;

    const proc = Bun.spawn(
      ["claude", "-p", "-", "--output-format", "json"],
      { stdout: "pipe", stderr: "pipe", stdin: new Response(prompt).body as ReadableStream },
    );
    const out = (await new Response(proc.stdout).text()).trim();
    const errOut = (await new Response(proc.stderr).text()).trim();
    const code = await proc.exited;
    if (code !== 0 || !out) {
      if (errOut) error(errOut);
      else error(`claude exited with code ${code}`);
      return null;
    }

    let text = out;
    try {
      const wrapper = JSON.parse(text);
      text = typeof wrapper === "string" ? wrapper : wrapper.result ?? text;
    } catch {}
    text = text.replace(/^```(?:json)?\s*\n?/m, "").replace(/\n?```\s*$/m, "").trim();

    const start = text.indexOf("[");
    const end = text.lastIndexOf("]");
    if (start === -1 || end === -1) return null;

    return JSON.parse(text.slice(start, end + 1));
  } catch (e: any) {
    error(`Commit plan failed: ${e?.message ?? e}`);
  }
  return null;
}

async function executeCommitPlan(plan: CommitPlan[]): Promise<string> {
  for (const commit of plan) {
    // reset staging
    await run(["git", "reset", "HEAD"], { cwd: DOTFILES, silent: true });
    // stage specific files
    for (const f of commit.files) {
      await run(["git", "add", f], { cwd: DOTFILES, silent: true });
    }
    const status = await stdout(["git", "status", "--porcelain"], { cwd: DOTFILES });
    if (!status) {
      log(sym.check, pc.dim(`Skipped (no changes): ${commit.message.split("\n")[0]}`));
      continue;
    }
    if (!(await run(["git", "commit", "-m", commit.message], { cwd: DOTFILES }))) {
      error(`Commit failed: ${commit.message.split("\n")[0]}`);
      // stage everything remaining and bail
      await run(["git", "add", "-A"], { cwd: DOTFILES, silent: true });
      break;
    }
    success(commit.message.split("\n")[0]);
  }

  // catch any unstaged leftovers
  await run(["git", "add", "-A"], { cwd: DOTFILES, silent: true });
  const leftover = await stdout(["git", "status", "--porcelain"], { cwd: DOTFILES });
  if (leftover) {
    log(sym.gear, pc.dim("Committing remaining changes..."));
    await run(["git", "commit", "-m", "chore: remaining changes"], { cwd: DOTFILES });
  }

  return await stdout(["git", "rev-parse", "--short", "HEAD"], { cwd: DOTFILES });
}

async function switchConfig(label: string) {
  log(sym.rocket, pc.magenta("Building and switching configuration..."));
  let envArgs: string[] = [];
  try {
    const envContent = await readFile(join(DOTFILES, ".env"), "utf-8");
    envArgs = envContent.split("\n").filter(l => l.trim() && !l.startsWith("#"));
  } catch {}
  envArgs.push(`NIXOS_LABEL=${label}`);

  if (await run(["sudo", "env", ...envArgs, "nixos-rebuild", "switch", "--impure", "--flake", FLAKE])) {
    success(`Generation: ${label}`);
  } else {
    error("Switch failed");
    process.exit(1);
  }
}

async function commitAndSwitch() {
  await run(["git", "add", "-A"], { cwd: DOTFILES });
  const plan = await generateCommitPlan();
  if (!plan || !plan.length) {
    log(sym.check, pc.dim("No changes to commit"));
    return;
  }
  // preview
  console.log(`\n  ${pc.bold("Commit plan:")}\n`);
  for (const c of plan) {
    const [subject, ...body] = c.message.split("\n");
    console.log(`  ${pc.green("\u2022")} ${pc.bold(subject)}`);
    for (const l of body) {
      if (l.trim()) console.log(`    ${pc.dim(l)}`);
    }
    console.log(`    ${pc.dim(c.files.join(", "))}`);
    console.log();
  }
  console.log(`  ${pc.yellow("enter")} confirm  ${pc.yellow("esc")} cancel`);

  const confirmed = await new Promise<boolean>(resolve => {
    const stop = startRaw((key) => {
      if (key === "enter") { stop(); resolve(true); }
      else if (key === "esc") { stop(); resolve(false); }
    });
  });
  if (!confirmed) {
    log(sym.check, pc.dim("Cancelled"));
    return;
  }

  console.log();
  const hash = await executeCommitPlan(plan);
  const lastMsg = plan[plan.length - 1].message.split("\n")[0];
  const label = sanitizeLabel(`${hash}-${lastMsg}`);
  await switchConfig(label);
}

async function genSwitch() {
  await commitAndSwitch();
}

// diff helpers

function extractHash(label: string): string | null {
  const m = label.match(/^([a-f0-9]{7,})-/);
  return m ? m[1] : null;
}

async function savedDiff(genId: string): Promise<string | null> {
  const path = join(DIFF_DIR, `${genId}.diff`);
  try { return await readFile(path, "utf-8"); } catch { return null; }
}

async function saveDiff(genId: string, diff: string) {
  if (!existsSync(DIFF_DIR)) await mkdir(DIFF_DIR, { recursive: true });
  await writeFile(join(DIFF_DIR, `${genId}.diff`), diff);
}

interface SavedBuild {
  id: number;
  genId?: string;
  status: "success" | "error" | "cancelled";
  log: string[];
  startedAt: string;
  label: string;
}

async function loadBuilds(): Promise<Build[]> {
  if (!existsSync(BUILD_DIR)) return [];
  const { readdir } = await import("node:fs/promises");
  const files = await readdir(BUILD_DIR);
  const builds: Build[] = [];
  for (const f of files.filter(f => f.endsWith(".json")).sort().reverse()) {
    try {
      const data: SavedBuild = JSON.parse(await readFile(join(BUILD_DIR, f), "utf-8"));
      builds.push({
        ...data,
        startedAt: new Date(data.startedAt),
      });
    } catch {}
  }
  return builds.slice(0, 20);
}

async function saveBuild(build: Build) {
  if (!existsSync(BUILD_DIR)) await mkdir(BUILD_DIR, { recursive: true });
  const ts = build.startedAt.toISOString().replace(/[:.]/g, "-");
  const data: SavedBuild = {
    id: build.id,
    genId: build.genId,
    status: build.status as "success" | "error" | "cancelled",
    log: build.log,
    startedAt: build.startedAt.toISOString(),
    label: build.label,
  };
  await writeFile(join(BUILD_DIR, `${ts}.json`), JSON.stringify(data));
  // prune old builds (keep 20)
  const { readdir } = await import("node:fs/promises");
  const { unlink } = await import("node:fs/promises");
  const files = (await readdir(BUILD_DIR)).filter(f => f.endsWith(".json")).sort();
  if (files.length > 20) {
    for (const f of files.slice(0, files.length - 20)) {
      await unlink(join(BUILD_DIR, f)).catch(() => {});
    }
  }
}

async function commitMsg(hash: string): Promise<string> {
  return await stdout(["git", "log", "-1", "--format=%B", hash], { cwd: DOTFILES });
}

async function genDiff(gen: Gen, prevGen: Gen | null): Promise<string> {
  const hash = extractHash(gen.label);
  const prevHash = prevGen ? extractHash(prevGen.label) : null;

  // labeled gen with commit hash: show git diff between commits
  if (hash && prevHash) {
    const diff = await stdout(["git", "diff", "-p", `${prevHash}..${hash}`], { cwd: DOTFILES });
    return diff || "(empty diff)";
  }
  if (hash) {
    const diff = await stdout(["git", "show", "-p", "--format=", hash], { cwd: DOTFILES });
    return diff || "(empty diff)";
  }

  // unlabeled: check saved diff
  const saved = await savedDiff(gen.id);
  if (saved) return saved;

  return "(no diff available)";
}

// colorize diff output

function colorDiff(lines: string[]): string[] {
  return lines.flatMap(l => {
    if (l.startsWith("+") && !l.startsWith("+++")) return pc.green(l);
    if (l.startsWith("-") && !l.startsWith("---")) return pc.red(l);
    if (l.startsWith("@@")) return pc.cyan(l);
    if (l.startsWith("diff --git")) return ["", pc.bold(pc.yellow(l))];
    if (l.startsWith("---") || l.startsWith("+++")) return pc.dim(l);
    if (l.startsWith("index ")) return pc.dim(l);
    return l;
  });
}

// file tree helpers

interface TreeNode {
  name: string;
  children: TreeNode[];
  stat?: { add: number; del: number };
}

function buildTree(files: string[], stats: Map<string, { add: number; del: number }>): TreeNode {
  const root: TreeNode = { name: "", children: [] };
  for (const f of files) {
    const parts = f.split("/");
    let node = root;
    for (let i = 0; i < parts.length; i++) {
      const name = parts[i];
      let child = node.children.find(c => c.name === name);
      if (!child) {
        child = { name, children: [] };
        node.children.push(child);
      }
      if (i === parts.length - 1) child.stat = stats.get(f);
      node = child;
    }
  }
  function collapse(n: TreeNode): TreeNode {
    if (n.children.length === 1 && !n.stat && n.children[0].children.length > 0) {
      const child = n.children[0];
      return collapse({ name: n.name ? `${n.name}/${child.name}` : child.name, children: child.children });
    }
    n.children = n.children.map(collapse);
    return n;
  }
  return collapse(root);
}

function renderTree(node: TreeNode, prefix: string): string[] {
  // collect all entries with their prefix+label for alignment
  interface Entry { line: string; stat?: { add: number; del: number } }
  const entries: Entry[] = [];

  if (node.name) {
    entries.push({ line: `${prefix}${pc.dim(node.name + "/")}` });
  }

  function collect(n: TreeNode, pfx: string) {
    for (let i = 0; i < n.children.length; i++) {
      const child = n.children[i];
      const last = i === n.children.length - 1;
      const connector = last ? "\u2514\u2500 " : "\u251c\u2500 ";
      const label = child.children.length > 0 && !child.stat
        ? pc.dim(child.name + "/")
        : child.name;
      entries.push({ line: `${pfx}${connector}${label}`, stat: child.stat });
      if (child.children.length > 0) {
        collect(child, pfx + (last ? "   " : "\u2502  "));
      }
    }
  }
  collect(node, prefix);

  // find max visible width of lines with stats for alignment
  const statEntries = entries.filter(e => e.stat);
  const maxW = statEntries.reduce((m, e) => Math.max(m, visWidth(e.line)), 0);

  return entries.map(e => {
    if (!e.stat) return e.line;
    const pad = " ".repeat(Math.max(2, maxW - visWidth(e.line) + 2));
    return `${e.line}${pad}${pc.green(`+${e.stat.add}`)} ${pc.red(`-${e.stat.del}`)}`;
  });
}

function diffSummary(raw: string): string[] {
  const lines = raw.split("\n");
  const diffFiles = lines.filter(l => l.startsWith("diff --git"));
  const totalAdds = lines.filter(l => l.startsWith("+") && !l.startsWith("+++")).length;
  const totalDels = lines.filter(l => l.startsWith("-") && !l.startsWith("---")).length;

  // per-file stats from the diff
  const stats = new Map<string, { add: number; del: number }>();
  let currentFile: string | null = null;
  for (const l of lines) {
    const m = l.match(/^diff --git a\/(.+) b\//);
    if (m) {
      currentFile = m[1];
      stats.set(currentFile, { add: 0, del: 0 });
    } else if (currentFile) {
      if (l.startsWith("+") && !l.startsWith("+++")) {
        stats.get(currentFile)!.add++;
      } else if (l.startsWith("-") && !l.startsWith("---")) {
        stats.get(currentFile)!.del++;
      }
    }
  }

  const filePaths = diffFiles.map(l => {
    const m = l.match(/diff --git a\/(.+) b\//);
    return m ? m[1] : "";
  }).filter(Boolean);

  const summary: string[] = [];
  summary.push(pc.bold(`${filePaths.length} file${filePaths.length !== 1 ? "s" : ""} changed`) +
    `  ${pc.green(`+${totalAdds}`)}  ${pc.red(`-${totalDels}`)}`);
  summary.push("");

  const tree = buildTree(filePaths, stats);
  summary.push(...renderTree(tree, ""));
  summary.push("");
  return summary;
}

// dashboard

type GenTab = "generations" | "builds";
const GEN_TAB_ORDER: GenTab[] = ["generations", "builds"];
const GEN_TABS = [
  { key: "g", label: "generations" },
  { key: "b", label: "builds" },
];

interface Build {
  id: number;
  genId?: string;
  status: "running" | "success" | "error" | "cancelled";
  log: string[];
  startedAt: Date;
  label: string;
  proc?: ReturnType<typeof Bun.spawn>;
}

interface DashState {
  gens: Gen[];
  cursor: number;
  diff: string[];
  rawDiff: string;
  status: string;
  leftScroll: Scroll;
  rightScroll: Scroll;
  pane: "left" | "right";
  gcMarked: Set<string>;
  tab: GenTab;
  builds: Build[];
  buildCursor: number;
  buildScroll: Scroll;
  buildNextId: number;
}

export async function genDash() {
  const s: DashState = {
    gens: [], cursor: 0, diff: [], rawDiff: "", status: "Loading...",
    leftScroll: mkScroll(), rightScroll: mkScroll(), pane: "left" as const,
    gcMarked: new Set(),
    tab: "generations",
    builds: [], buildCursor: 0, buildListScroll: mkScroll(), buildScroll: mkScroll(), buildFocus: 1, buildNextId: 1,
  };

  const cols = () => process.stdout.columns ?? 100;
  const rows = () => process.stdout.rows ?? 24;

  const widths = () => columnWidths([35, 65]);

  const draw = () => {
    const { panels, w } = s.tab === "generations"
      ? buildGenPanels()
      : buildBuildPanels();
    appShell({
      tabs: GEN_TABS,
      activeTab: GEN_TAB_ORDER.indexOf(s.tab),
      panels,
      widths: w,
      status: s.status,
      keys: currentKeys(),
    });
  };

  function buildGenPanels(): { panels: PanelDef[]; w: number[] } {
    const w = widths();
    const left: string[] = [];
    const gcActive = s.gcMarked.size > 0;
    for (let i = 0; i < s.gens.length; i++) {
      const g = s.gens[i];
      const marked = s.gcMarked.has(g.id);
      const prefix = i === s.cursor ? pc.yellow("\u25B6 ") : "  ";
      const tag = g.current ? pc.green(" \u2022") : "";
      const isDefault = !g.label || /^\d+\.\d+\./.test(g.label) || g.label === "unlabeled";
      const label = isDefault ? pc.dim("unlabeled") : truncate(g.label, w[0] - 16);
      if (marked) {
        const gcTag = pc.red(" \u2717");
        left.push(`${prefix}${pc.dim(g.id)} ${pc.dim(g.date)}${gcTag}`);
        left.push(`    ${pc.strikethrough(pc.dim(String(label)))}`);
      } else if (gcActive) {
        const keepTag = pc.green(" \u2713");
        left.push(`${prefix}${pc.bold(g.id)} ${pc.dim(g.date)}${keepTag}${tag}`);
        left.push(`    ${label}`);
      } else {
        left.push(`${prefix}${pc.bold(g.id)} ${pc.dim(g.date)}${tag}`);
        left.push(`    ${label}`);
      }
      if (i < s.gens.length - 1) left.push("");
    }
    if (!s.gens.length) left.push(pc.dim("No generations"));

    const right = s.diff.length ? s.diff : [pc.dim("No diff")];

    const panels: PanelDef[] = [
      { lines: left, scroll: s.leftScroll, focused: s.pane === "left", cursor: true },
      { lines: right, scroll: s.rightScroll, focused: s.pane === "right" },
    ];
    return { panels, w };
  }

  function formatBuildLog(lines: string[]): string[] {
    // separate warnings from log lines
    const warnings = new Map<string, { count: number; eval: boolean }>();
    const log: string[] = [];

    for (const raw of lines) {
      const warnMatch = raw.match(/^warning:\s*(.+)/);
      const evalMatch = raw.match(/^evaluation warning:\s*(.+)/);
      if (warnMatch) {
        const msg = warnMatch[1];
        const entry = warnings.get(msg);
        if (entry) {
          entry.count++;
        } else {
          warnings.set(msg, { count: 1, eval: false });
        }
      } else if (evalMatch) {
        const msg = evalMatch[1];
        const entry = warnings.get(msg);
        if (entry) {
          entry.count++;
        } else {
          warnings.set(msg, { count: 1, eval: true });
        }
      } else {
        log.push(raw);
      }
    }

    const out: string[] = [];

    if (warnings.size > 0) {
      out.push(pc.bold(pc.yellow(" warnings")));
      out.push("");
      for (const [msg, { count, eval: isEval }] of warnings) {
        const tags: string[] = [];
        if (count > 1) tags.push(pc.yellow(`x${count}`));
        if (isEval) tags.push(pc.yellow("eval"));
        const suffix = tags.length ? `  ${pc.dim("(")}${tags.join(", ")}${pc.dim(")")}` : "";
        out.push(` ${pc.dim(msg)}${suffix}`);
      }
      out.push("");
    }

    if (log.length > 0) {
      out.push(pc.bold(pc.cyan(" logs")));
      out.push("");
      for (const l of log) {
        out.push(" " + colorBuildLine(l));
      }
    }

    return out;
  }

  function colorBuildLine(line: string): string {
    // nix store paths
    return line.replace(/\/nix\/store\/[a-z0-9]{32}-[^\s]*/g, (m) => pc.dim(m));
  }

  function buildBuildPanels(): { panels: PanelDef[]; w: number[] } {
    const w = widths();
    const left: string[] = [];
    if (!s.builds.length) {
      left.push(pc.dim("No builds yet"));
    } else {
      for (let i = 0; i < s.builds.length; i++) {
        const b = s.builds[i];
        const prefix = i === s.buildCursor ? pc.yellow("\u25B6 ") : "  ";
        const icon = b.status === "running" ? pc.yellow("\u25CB")
          : b.status === "success" ? pc.green("\u2713")
          : b.status === "cancelled" ? pc.yellow("\u2717")
          : pc.red("\u2717");
        const time = fmtTime(b.startedAt);
        const label = truncVis(b.label, w[0] - 14);
        left.push(`${prefix}${icon} ${pc.dim(time)} ${label}`);
      }
    }

    const build = s.builds[s.buildCursor];
    const right = build?.log.length
      ? formatBuildLog(build.log)
      : [pc.dim("No output")];

    const panels: PanelDef[] = [
      { lines: left, scroll: s.buildListScroll, focused: s.buildFocus === 0, cursor: true },
      { lines: right, scroll: s.buildScroll, focused: s.buildFocus === 1 },
    ];
    return { panels, w };
  }

  function fmtTime(d: Date): string {
    return `${String(d.getHours()).padStart(2, "0")}:${String(d.getMinutes()).padStart(2, "0")}`;
  }

  function currentKeys(): Keys {
    if (s.tab === "generations") {
      if (s.pane === "right") {
        return [["up", ""], ["down", ""], ["left", ""], ["right", ""]];
      }
      const gcCount = s.gcMarked.size;
      if (gcCount > 0) {
        return [
          ["up", ""], ["down", ""],
          ["space", "toggle"], ["enter", `delete ${gcCount}`], ["esc", "cancel"],
        ];
      }
      return [
        ["up", ""], ["down", ""], ["right", "diff"],
        ["p", "pick"], ["r", "regen"], ["c", "commit"], ["G", "gc"],
      ];
    }
    // builds tab
    const build = s.builds[s.buildCursor];
    const keys: Keys = [
      ["up", ""], ["down", ""],
      ["left", ""], ["right", ""],
    ];
    if (build?.status === "running") {
      keys.push(["x", "cancel"]);
    } else {
      keys.push(["r", "regen"], ["c", "commit"]);
      if (build?.genId) keys.push(["s", "show gen"]);
    }
    return keys;
  }

  async function loadDiff() {
    if (!s.gens.length) { s.diff = []; s.rawDiff = ""; return; }
    const gen = s.gens[s.cursor];
    const prev = s.cursor < s.gens.length - 1 ? s.gens[s.cursor + 1] : null;
    s.rightScroll = mkScroll();
    s.pane = "left";
    const raw = await genDiff(gen, prev);
    s.rawDiff = raw;
    const hash = extractHash(gen.label);
    const msg = hash ? await commitMsg(hash) : "";
    const header: string[] = [];
    if (msg) {
      header.push(pc.bold(msg.split("\n")[0]));
      const rest = msg.split("\n").slice(1).filter(l => l.trim());
      if (rest.length) header.push(...rest.map(l => pc.dim(l)));
      header.push("");
    }
    const summary = diffSummary(raw);
    s.diff = [...header, ...summary, ...colorDiff(raw.split("\n"))];
    s.status = "";
  }

  async function refresh() {
    s.gens = await listGens();
    if (s.cursor >= s.gens.length) s.cursor = Math.max(0, s.gens.length - 1);
    await loadDiff();
  }

  function spawnBuild(label: string, extraLabel?: string) {
    const build: Build = {
      id: s.buildNextId++,
      status: "running",
      log: [],
      startedAt: new Date(),
      label: extraLabel ?? label,
    };
    s.builds.unshift(build);
    s.buildCursor = 0;
    s.buildScroll = mkScroll();
    s.tab = "builds";
    draw();

    (async () => {
      let envArgs: string[] = [];
      try {
        const envContent = await readFile(join(DOTFILES, ".env"), "utf-8");
        envArgs = envContent.split("\n").filter(l => l.trim() && !l.startsWith("#"));
      } catch {}
      if (label) envArgs.push(`NIXOS_LABEL=${label}`);

      const proc = Bun.spawn(
        ["sudo", "env", ...envArgs, "nixos-rebuild", "switch", "--impure", "--flake", FLAKE],
        { stdout: "pipe", stderr: "pipe" },
      );
      build.proc = proc;

      const readStream = async (stream: ReadableStream<Uint8Array>) => {
        const reader = stream.getReader();
        const decoder = new TextDecoder();
        let partial = "";
        while (true) {
          const { done, value } = await reader.read();
          if (done) break;
          partial += decoder.decode(value, { stream: true });
          const lines = partial.split("\n");
          partial = lines.pop()!;
          for (const line of lines) {
            build.log.push(line);
            autoScrollLog(build);
            draw();
          }
        }
        if (partial) {
          build.log.push(partial);
          autoScrollLog(build);
          draw();
        }
      };

      await Promise.all([
        readStream(proc.stdout as ReadableStream<Uint8Array>),
        readStream(proc.stderr as ReadableStream<Uint8Array>),
      ]);

      const code = await proc.exited;
      if (build.status === "cancelled") {
        // already marked cancelled by user
      } else {
        build.status = code === 0 ? "success" : "error";
      }

      if (code === 0 && build.status !== "cancelled") {
        // save diff for regen builds
        const diff = await stdout(["git", "diff"], { cwd: DOTFILES });
        const staged = await stdout(["git", "diff", "--cached"], { cwd: DOTFILES });
        const fullDiff = [staged, diff].filter(Boolean).join("\n");
        const gens = await listGens();
        const current = gens.find(g => g.current);
        if (current) {
          build.genId = current.id;
          if (fullDiff) await saveDiff(current.id, fullDiff);
        }
        s.gens = gens;
        if (s.cursor >= s.gens.length) s.cursor = Math.max(0, s.gens.length - 1);
      }

      await saveBuild(build);
      draw();
    })();
  }

  function autoScrollLog(build: Build) {
    if (s.builds[s.buildCursor] !== build) return;
    const innerH = Math.max(1, rows() - 3); // tab + header(1) + menu(1)
    const formatted = formatBuildLog(build.log);
    const maxScroll = Math.max(0, formatted.length - innerH);
    if (s.buildScroll.v >= maxScroll - 2) {
      s.buildScroll.v = maxScroll;
    }
  }

  async function doRegen() {
    await run(["git", "add", "-A"], { cwd: DOTFILES, silent: true });
    spawnBuild("", "regen");
  }

  async function fileStats(files: string[]): Promise<Map<string, { add: number; del: number }>> {
    const out = await stdout(
      ["git", "diff", "--cached", "--numstat", "--", ...files],
      { cwd: DOTFILES },
    );
    const stats = new Map<string, { add: number; del: number }>();
    for (const line of out.split("\n")) {
      const m = line.match(/^(\d+)\t(\d+)\t(.+)$/);
      if (m) stats.set(m[3], { add: parseInt(m[1]), del: parseInt(m[2]) });
    }
    return stats;
  }

  async function doCommit(): Promise<void> {
    // exit raw mode for commit planning
    await run(["git", "add", "-A"], { cwd: DOTFILES });
    const plan = await generateCommitPlan();
    if (!plan || !plan.length) {
      log(sym.check, pc.dim("No changes to commit"));
      return;
    }
    // preview
    console.log(`\n  ${pc.bold("Commit plan:")}\n`);
    for (const c of plan) {
      const [subject, ...body] = c.message.split("\n");
      console.log(`  ${pc.green("\u2022")} ${pc.bold(subject)}`);
      for (const l of body) {
        if (l.trim()) console.log(`    ${pc.dim(l)}`);
      }
      const stats = await fileStats(c.files);
      const tree = buildTree(c.files, stats);
      for (const line of renderTree(tree, "    ")) {
        console.log(line);
      }
      console.log();
    }
    console.log(`  ${pc.yellow("enter")} confirm  ${pc.yellow("esc")} cancel`);

    const confirmed = await new Promise<boolean>(resolve => {
      const stop = startRaw((key) => {
        if (key === "enter") { stop(); resolve(true); }
        else if (key === "esc") { stop(); resolve(false); }
      });
    });
    if (!confirmed) {
      log(sym.check, pc.dim("Cancelled"));
      return;
    }

    console.log();
    const hash = await executeCommitPlan(plan);
    const lastMsg = plan[plan.length - 1].message.split("\n")[0];
    const label = sanitizeLabel(`${hash}-${lastMsg}`);
    spawnBuild(label, `commit: ${lastMsg}`);
  }

  function isLabeled(g: Gen): boolean {
    return !!g.label && !/^\d+\.\d+\./.test(g.label) && g.label !== "unlabeled";
  }

  function isRecent(g: Gen): boolean {
    const d = new Date(g.date);
    return !isNaN(d.getTime()) && Date.now() - d.getTime() < 14 * 24 * 60 * 60 * 1000;
  }

  function computeGcMarked() {
    const labeled = s.gens.filter(g => isLabeled(g));
    const unlabeled = s.gens.filter(g => !isLabeled(g));
    const labeledToRemove = labeled.slice(10);
    const toRemove = [
      ...unlabeled.filter(g => !g.current),
      ...labeledToRemove.filter(g => !g.current && !isRecent(g)),
    ];
    s.gcMarked = new Set(toRemove.map(g => g.id));
    if (!s.gcMarked.size) {
      s.status = "Nothing to clean up";
    } else {
      s.status = `${s.gcMarked.size} to remove, ${s.gens.length - s.gcMarked.size} to keep`;
    }
  }

  async function doPickGen() {
    if (!s.gens.length) return;
    const gen = s.gens[s.cursor];
    if (gen.current) {
      log(sym.check, pc.dim("Already on this generation"));
      return;
    }
    console.log(`\n  Switch to generation ${pc.bold(gen.id)}?`);
    console.log(`  ${pc.dim(gen.date)}  ${gen.label || pc.dim("unlabeled")}\n`);
    const confirm = await input({ message: "Type 'yes' to confirm" });
    if (confirm !== "yes") {
      log(sym.check, pc.dim("Cancelled"));
      return;
    }
    const path = `${PROFILE}-${gen.id}-link`;
    log(sym.refresh, pc.yellow(`Switching to generation ${gen.id}...`));
    if (await run(["sudo", path + "/bin/switch-to-configuration", "switch"])) {
      success(`Switched to generation ${gen.id}`);
    } else {
      error("Switch failed");
    }
  }

  // initial load
  s.builds = await loadBuilds();
  s.buildNextId = s.builds.reduce((m, b) => Math.max(m, b.id), 0) + 1;
  await refresh();
  draw();

  // event loop: exits raw mode for shell commands, re-enters after
  while (true) {
    const action = await new Promise<string>((resolve) => {
      const stop = startRaw(async (key) => {
        // standard keys (quit + tab switching)
        const canSwitch = s.pane === "left" && s.gcMarked.size === 0;
        const stdResult = handleStdKey(
          key, GEN_TAB_ORDER.length, GEN_TAB_ORDER.indexOf(s.tab),
          { g: 0, b: 1 }, canSwitch,
        );
        if (stdResult) {
          if (stdResult.action === "quit") { stop(); resolve("quit"); return; }
          s.tab = GEN_TAB_ORDER[stdResult.index];
          s.pane = "left";
          draw();
          return;
        }

        const viewH = Math.max(5, rows() - 3);

        // generations tab
        if (s.tab === "generations") {
          if (s.gcMarked.size > 0) {
            if (key === "esc") { s.gcMarked = new Set(); s.status = ""; draw(); return; }
            if (key === "enter") { stop(); resolve("gc-confirm"); return; }
            if (key === "up" && s.cursor > 0) { s.cursor--; draw(); loadDiff().then(draw); return; }
            if (key === "down" && s.cursor < s.gens.length - 1) { s.cursor++; draw(); loadDiff().then(draw); return; }
            if (key === " " && s.gens[s.cursor] && !s.gens[s.cursor].current) {
              const id = s.gens[s.cursor].id;
              if (s.gcMarked.has(id)) s.gcMarked.delete(id); else s.gcMarked.add(id);
              s.status = s.gcMarked.size
                ? `${s.gcMarked.size} to remove, ${s.gens.length - s.gcMarked.size} to keep`
                : "";
              if (s.cursor < s.gens.length - 1) { s.cursor++; draw(); loadDiff().then(draw); }
              else { draw(); }
              return;
            }
            return;
          }

          const focusIdx = s.pane === "left" ? 0 : 1;
          const leftNav = { kind: "cursor" as const, pos: s.cursor, count: s.gens.length };
          const navPanels = [
            { scroll: s.leftScroll, nav: leftNav },
            { scroll: s.rightScroll, nav: { kind: "scroll" as const, count: s.diff.length, hScroll: true } },
          ];
          const act = columnsNav(key, navPanels, focusIdx);
          if (act) {
            if (act.type === "focus") {
              if (act.index === 1 && !s.diff.length) { draw(); return; }
              s.pane = act.index === 0 ? "left" : "right";
            } else if (act.type === "cursor") {
              s.cursor = leftNav.pos;
              s.rightScroll = mkScroll();
              draw();
              loadDiff().then(draw);
              return;
            }
            draw();
            return;
          }

          if (s.pane === "left") {
            if (key === "p") { stop(); resolve("pick"); }
            else if (key === "r") { stop(); resolve("regen"); }
            else if (key === "c") { stop(); resolve("commit"); }
            else if (key === "G") { computeGcMarked(); draw(); }
          }
          return;
        }

        // builds tab
        if (s.tab === "builds") {
          const build = s.builds[s.buildCursor];
          const logLen = build?.log.length ?? 0;
          const buildFocus = s.buildFocus;
          const buildLeftNav = { kind: "cursor" as const, pos: s.buildCursor, count: s.builds.length };
          const navPanels = [
            { scroll: s.buildListScroll, nav: buildLeftNav },
            { scroll: s.buildScroll, nav: { kind: "scroll" as const, count: logLen, hScroll: true } },
          ];
          const act = columnsNav(key, navPanels, buildFocus);
          if (act) {
            if (act.type === "focus") {
              s.buildFocus = act.index;
            } else if (act.type === "cursor" && buildFocus === 0) {
              s.buildCursor = buildLeftNav.pos;
              s.buildScroll = mkScroll();
            }
            draw();
            return;
          }

          if (build?.status === "running" && key === "x" && build.proc) {
            build.status = "cancelled";
            build.proc.kill();
            build.log.push("", "Build cancelled by user");
            draw();
            return;
          }
          if (build?.status !== "running") {
            if (key === "r") { stop(); resolve("regen"); return; }
            if (key === "c") { stop(); resolve("commit"); return; }
            if (key === "s" && build?.genId) {
              s.tab = "generations";
              const idx = s.gens.findIndex(g => g.id === build.genId);
              if (idx >= 0) {
                s.cursor = idx;
                s.rightScroll = mkScroll();
                loadDiff().then(draw);
              }
              draw();
              return;
            }
          }
        }
      });
    });

    if (action === "quit") break;

    console.log();
    if (action === "regen") {
      doRegen();
      draw();
    } else if (action === "commit") {
      await doCommit();
      console.log(pc.dim("\nPress any key to return..."));
      await new Promise<void>(r => {
        const c = startRaw(() => { c(); r(); });
      });
      await refresh();
      draw();
    } else if (action === "gc-confirm") {
      const toRemove = s.gens.filter(g => s.gcMarked.has(g.id));
      log(sym.broom, pc.yellow(`Removing ${toRemove.length} generation${toRemove.length > 1 ? "s" : ""}...`));
      for (const g of toRemove) {
        await run(["sudo", "rm", "-f", `${PROFILE}-${g.id}-link`], { silent: true });
      }
      log(sym.gear, pc.yellow("Running garbage collection..."));
      await run(["sudo", "nix-collect-garbage", "--delete-older-than", "14d"]);
      success("Cleanup complete!");
      s.gcMarked = new Set();
      console.log(pc.dim("\nPress any key to return..."));
      await new Promise<void>(r => {
        const c = startRaw(() => { c(); r(); });
      });
      s.cursor = 0;
      await refresh();
    } else if (action === "pick") {
      await doPickGen();
      console.log(pc.dim("\nPress any key to return..."));
      await new Promise<void>(r => {
        const c = startRaw(() => { c(); r(); });
      });
      s.cursor = 0;
      await refresh();
    }
  }
}

export default function register(program: Command) {
  const gen = program
    .command("gen")
    .description("NixOS generation management");

  gen
    .command("switch")
    .description("Commit, label, and rebuild NixOS configuration")
    .action(genSwitch);

  gen
    .command("list")
    .description("List NixOS generations")
    .option("-n, --lines <n>", "Number of entries", "20")
    .action(async (opts) => {
      const gens = await listGens();
      if (!gens.length) {
        error("No generations found");
        return;
      }
      for (const g of gens.slice(0, parseInt(opts.lines))) {
        const tag = g.current ? pc.green(" *") : "";
        const isDefault = !g.label || /^\d+\.\d+\./.test(g.label) || g.label === "unlabeled";
        const label = isDefault ? "" : pc.dim(`  ${g.label}`);
        console.log(`${pc.bold(g.id)}  ${g.date}${label}${tag}`);
      }
    });

  gen
    .command("update")
    .description("Update flake inputs and switch")
    .action(async () => {
      if (!(await run(["sudo", "nix", "flake", "update"], { cwd: DOTFILES }))) {
        error("Flake update failed");
        process.exit(1);
      }
      await genSwitch();
    });

  gen
    .command("back")
    .description("Rollback to previous generation")
    .action(async () => {
      log(sym.refresh, pc.yellow("Rolling back..."));
      if (await run(["sudo", "nixos-rebuild", "switch", "--rollback"])) {
        success("Rolled back!");
      } else {
        error("Rollback failed");
        process.exit(1);
      }
    });

  gen
    .command("pick")
    .description("Interactively switch to a past generation")
    .action(async () => {
      const gens = await listGens();
      if (!gens.length) {
        error("No generations found");
        return;
      }
      const selected = await search({
        message: "Switch to generation",
        source: (term) => {
          const q = term.toLowerCase();
          return gens
            .filter((g) => !q || g.id.includes(q) || g.date.includes(q) || g.label.includes(q))
            .reverse()
            .map((g) => ({
              name: `${g.id}  ${g.date}  ${g.label}${g.current ? pc.green(" *") : ""}`,
              value: g.id,
            }));
        },
      });
      if (!selected) return;
      const path = `${PROFILE}-${selected}-link`;
      log(sym.refresh, pc.yellow(`Switching to generation ${selected}...`));
      if (await run(["sudo", path + "/bin/switch-to-configuration", "switch"])) {
        success(`Switched to generation ${selected}`);
      } else {
        error("Switch failed");
        process.exit(1);
      }
    });

  gen
    .command("gc")
    .description("Garbage collect old generations")
    .action(async () => {
      log(sym.broom, pc.yellow("Cleaning up old generations..."));
      if (!(await run(["sudo", "nix-collect-garbage", "--delete-older-than", GC_KEEP_DAYS]))) {
        error("Garbage collection failed");
        process.exit(1);
      }
      success("Old generations removed!");

      log(sym.gear, pc.yellow("Optimizing nix store..."));
      if (await run(["nix-store", "--optimise"])) {
        success("Cleanup complete!");
      } else {
        error("Store optimization failed");
        process.exit(1);
      }
    });
}
