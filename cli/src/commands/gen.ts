import type { Command } from "commander";
import pc from "picocolors";
import {
  input, search, clear, flush, startRaw, menuBar, renderSplit, sliceVis,
  type Keys,
} from "../lib/tui.ts";
import { readFile, writeFile, mkdir } from "node:fs/promises";
import { existsSync } from "node:fs";
import { join } from "node:path";
import { DOTFILES, FLAKE, sym, log, success, error, run } from "../utils.ts";
import { truncate } from "../lib/interactive.ts";

const GC_KEEP_DAYS = "7d";
const PROFILE = "/nix/var/nix/profiles/system";
const DIFF_DIR = `${process.env.HOME}/.local/share/yo/gen-diffs`;

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
      ["claude", "-p", prompt, "--output-format", "json"],
      { stdout: "pipe", stderr: "pipe" },
    );
    const out = (await new Response(proc.stdout).text()).trim();
    const code = await proc.exited;
    if (code !== 0 || !out) return null;

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
  } catch {}
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
  return lines.map(l => {
    if (l.startsWith("+") && !l.startsWith("+++")) return pc.green(l);
    if (l.startsWith("-") && !l.startsWith("---")) return pc.red(l);
    if (l.startsWith("@@")) return pc.cyan(l);
    if (l.startsWith("diff --git")) return `\n${pc.bold(pc.yellow(l))}`;
    if (l.startsWith("---") || l.startsWith("+++")) return pc.dim(l);
    if (l.startsWith("index ")) return pc.dim(l);
    return l;
  });
}

function diffSummary(raw: string): string[] {
  const lines = raw.split("\n");
  // extract --stat style summary (files changed, insertions, deletions)
  const files = lines.filter(l => l.startsWith("diff --git"));
  const adds = lines.filter(l => l.startsWith("+") && !l.startsWith("+++")).length;
  const dels = lines.filter(l => l.startsWith("-") && !l.startsWith("---")).length;

  const summary: string[] = [];
  summary.push(pc.bold(`${files.length} file${files.length !== 1 ? "s" : ""} changed`) +
    `  ${pc.green(`+${adds}`)}  ${pc.red(`-${dels}`)}`);
  summary.push("");

  // list changed files
  for (const f of files) {
    const m = f.match(/diff --git a\/(.+) b\//);
    if (m) summary.push(`  ${pc.dim("\u2022")} ${m[1]}`);
  }
  summary.push("");
  summary.push(pc.dim("\u2500".repeat(40)));
  summary.push("");
  return summary;
}

// dashboard

interface DashState {
  gens: Gen[];
  cursor: number;
  diff: string[];
  rawDiff: string;
  status: string;
  scrollLeft: number;
  scrollRight: number;
  scrollH: number;
  focusDiff: boolean;
  gcMarked: Set<string>;
}

async function genDash() {
  const s: DashState = {
    gens: [], cursor: 0, diff: [], rawDiff: "", status: "Loading...",
    scrollLeft: 0, scrollRight: 0, scrollH: 0, focusDiff: false,
    gcMarked: new Set(),
  };

  const cols = () => process.stdout.columns ?? 100;
  const rows = () => process.stdout.rows ?? 24;

  const draw = () => {
    clear();
    const c = cols();
    const leftW = Math.floor(c * 0.35);
    const rightW = c - leftW - 3;

    // header
    console.log();
    console.log(`  ${pc.bold(pc.cyan("NixOS Generations"))}`);
    console.log();

    if (s.status) {
      console.log(`  ${pc.dim(s.status)}`);
      console.log();
    }

    // left: generation list
    const left: string[] = [];
    const gcActive = s.gcMarked.size > 0;
    for (let i = 0; i < s.gens.length; i++) {
      const g = s.gens[i];
      const marked = s.gcMarked.has(g.id);
      const prefix = i === s.cursor ? pc.yellow("\u25B6 ") : "  ";
      const tag = g.current ? pc.green(" \u2022") : "";
      const isDefault = !g.label || /^\d+\.\d+\./.test(g.label) || g.label === "unlabeled";
      const label = isDefault ? pc.dim("unlabeled") : truncate(g.label, leftW - 16);
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
    if (!s.gens.length) left.push(pc.dim("  No generations"));

    // right: diff (horizontal scroll + truncate to pane width)
    const right = s.diff.length
      ? s.diff.map(l => sliceVis(l, s.scrollH, rightW))
      : [pc.dim("No diff")];

    // viewport
    const used = 3 + (s.status ? 2 : 0) + 2; // header + status + menu
    const contentH = Math.max(1, rows() - used);
    const margin = 2;

    const leftCursor = left.findIndex(l => l.includes("\u25B6"));
    if (left.length <= contentH) {
      s.scrollLeft = 0;
    } else if (leftCursor >= 0) {
      if (leftCursor < s.scrollLeft) s.scrollLeft = leftCursor;
      else if (leftCursor >= s.scrollLeft + contentH) s.scrollLeft = leftCursor - contentH + 1;
    }

    const leftView = left.slice(s.scrollLeft, s.scrollLeft + contentH);
    const rightView = right.slice(s.scrollRight, s.scrollRight + contentH);
    while (leftView.length < contentH) leftView.push("");
    while (rightView.length < contentH) rightView.push("");

    renderSplit(leftView, rightView, leftW);

    const gcCount = s.gcMarked.size;
    const keys: Keys = s.focusDiff
      ? [["up", ""], ["down", ""], ["left", ""], ["right", ""], ["esc", "back"]]
      : gcCount > 0
      ? [
          ["up", ""], ["down", ""],
          ["space", "toggle"], ["enter", `delete ${gcCount}`], ["esc", "cancel"],
        ]
      : [
          ["up", ""], ["down", ""],
          ["enter", "diff"], ["p", "pick"],
          ["r", "regen"], ["c", "commit"], ["g", "gc"],
          ["esc", "quit"],
        ];
    menuBar(keys);
    flush();
  };

  async function loadDiff() {
    if (!s.gens.length) { s.diff = []; s.rawDiff = ""; return; }
    const gen = s.gens[s.cursor];
    const prev = s.cursor < s.gens.length - 1 ? s.gens[s.cursor + 1] : null;
    s.scrollRight = 0;
    s.scrollH = 0;
    s.focusDiff = false;
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

  async function doRegen() {
    const diff = await stdout(["git", "diff"], { cwd: DOTFILES });
    const staged = await stdout(["git", "diff", "--cached"], { cwd: DOTFILES });
    const fullDiff = [staged, diff].filter(Boolean).join("\n");

    log(sym.rocket, pc.magenta("Regenerating (no commit)..."));
    let envArgs: string[] = [];
    try {
      const envContent = await readFile(join(DOTFILES, ".env"), "utf-8");
      envArgs = envContent.split("\n").filter(l => l.trim() && !l.startsWith("#"));
    } catch {}

    const ok = await run(["sudo", "env", ...envArgs, "nixos-rebuild", "switch", "--impure", "--flake", FLAKE]);
    if (ok) {
      success("Regenerated!");
      const gens = await listGens();
      const current = gens.find(g => g.current);
      if (current && fullDiff) await saveDiff(current.id, fullDiff);
    } else {
      error("Regen failed");
    }
  }

  async function doCommit() {
    await commitAndSwitch();
  }

  async function waitForKey() {
    console.log(pc.dim("\nPress any key to return..."));
    await new Promise<void>(r => {
      const c = startRaw(() => { c(); r(); });
    });
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
  await refresh();
  draw();

  // event loop: exits raw mode for shell commands, re-enters after
  while (true) {
    const action = await new Promise<string>((resolve) => {
      const stop = startRaw(async (key) => {
        if (s.focusDiff) {
          if (key === "esc") { s.focusDiff = false; draw(); return; }
          const contentH = Math.max(1, rows() - (3 + (s.status ? 2 : 0) + 2));
          const maxScroll = Math.max(0, s.diff.length - contentH);
          if (key === "up" && s.scrollRight > 0) { s.scrollRight--; draw(); }
          else if (key === "down" && s.scrollRight < maxScroll) { s.scrollRight++; draw(); }
          else if (key === "right") { s.scrollH += 8; draw(); }
          else if (key === "left" && s.scrollH > 0) { s.scrollH = Math.max(0, s.scrollH - 8); draw(); }
          return;
        }

        // gc preview mode
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

        if (key === "esc" || key === "q") { stop(); resolve("quit"); return; }

        if (key === "up" && s.cursor > 0) {
          s.cursor--;
          s.scrollRight = 0; s.scrollH = 0;
          draw();
          loadDiff().then(draw);
        } else if (key === "down" && s.cursor < s.gens.length - 1) {
          s.cursor++;
          s.scrollRight = 0; s.scrollH = 0;
          draw();
          loadDiff().then(draw);
        } else if (key === "enter" && s.diff.length) {
          s.focusDiff = true;
          draw();
        } else if (key === "p") { stop(); resolve("pick"); }
        else if (key === "r") { stop(); resolve("regen"); }
        else if (key === "c") { stop(); resolve("commit"); }
        else if (key === "g") { computeGcMarked(); draw(); }
      });
    });

    if (action === "quit") break;

    console.log();
    if (action === "regen") await doRegen();
    else if (action === "commit") await doCommit();
    else if (action === "gc-confirm") {
      const toRemove = s.gens.filter(g => s.gcMarked.has(g.id));
      log(sym.broom, pc.yellow(`Removing ${toRemove.length} generation${toRemove.length > 1 ? "s" : ""}...`));
      for (const g of toRemove) {
        await run(["sudo", "rm", "-f", `${PROFILE}-${g.id}-link`], { silent: true });
      }
      log(sym.gear, pc.yellow("Running garbage collection..."));
      await run(["sudo", "nix-collect-garbage", "--delete-older-than", "14d"]);
      success("Cleanup complete!");
      s.gcMarked = new Set();
    }
    else if (action === "pick") await doPickGen();

    await waitForKey();
    s.cursor = 0;
    await refresh();
  }
}

export default function register(program: Command) {
  const gen = program
    .command("gen")
    .description("NixOS generation management");

  gen
    .command("dash")
    .description("Interactive generation dashboard with diffs")
    .action(genDash);

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
