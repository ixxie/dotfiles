import type { Command } from "commander";
import pc from "picocolors";
import { search } from "@inquirer/prompts";
import { readFile } from "node:fs/promises";
import { join } from "node:path";
import { DOTFILES, FLAKE, sym, log, success, error, run } from "../utils.ts";

const GC_KEEP_DAYS = "7d";
const PROFILE = "/nix/var/nix/profiles/system";

interface Gen {
  id: string;
  date: string;
  current: boolean;
}

async function listGens(): Promise<Gen[]> {
  const proc = Bun.spawn(
    ["sudo", "nix-env", "--list-generations", "--profile", PROFILE],
    { stdout: "pipe" },
  );
  const out = (await new Response(proc.stdout).text()).trim();
  if (!out) return [];
  return out.split("\n").map((line) => {
    const current = line.includes("(current)");
    const parts = line.trim().split(/\s+/);
    return { id: parts[0], date: `${parts[1]} ${parts[2]}`, current };
  });
}

async function stdout(cmd: string[], opts?: { cwd?: string }): Promise<string> {
  const proc = Bun.spawn(cmd, { stdout: "pipe", stderr: "pipe", cwd: opts?.cwd });
  const out = (await new Response(proc.stdout).text()).trim();
  const code = await proc.exited;
  return code === 0 ? out : "";
}

// sanitize for system.nixos.label (alphanumeric, hyphens, underscores, periods, colons)
function sanitizeLabel(s: string): string {
  return s.replace(/[^a-zA-Z0-9._:-]/g, "_").slice(0, 80);
}

async function commitMessage(explicit?: string): Promise<string> {
  if (explicit) return explicit;

  // try claude
  try {
    log(sym.gear, pc.dim("Generating commit message..."));
    const diff = await stdout(["git", "diff", "--cached", "--stat"], { cwd: DOTFILES });
    if (!diff) return timestamp();

    const proc = Bun.spawn(
      ["claude", "-p",
        `Write a concise one-line commit message (no prefix, no quotes, max 72 chars) for these dotfile changes. Ignore flake.lock / flake input updates — focus on actual config changes:\n\n${diff}`,
        "--output-format", "json"],
      { stdout: "pipe", stderr: "pipe" },
    );
    const out = (await new Response(proc.stdout).text()).trim();
    const code = await proc.exited;
    if (code !== 0 || !out) return timestamp();

    let text = out;
    try {
      const wrapper = JSON.parse(text);
      text = typeof wrapper === "string" ? wrapper : wrapper.result ?? text;
    } catch {}
    text = text.replace(/^["'\s]+|["'\s]+$/g, "").trim();
    if (text && text.length > 0 && text.length <= 120) return text;
  } catch {}

  return timestamp();
}

function timestamp(): string {
  return new Date().toISOString().replace(/[:.]/g, "-").slice(0, 19);
}

async function gitCommit(msg: string): Promise<string> {
  // stage everything
  if (!(await run(["git", "add", "-A"], { cwd: DOTFILES }))) {
    error("git add failed");
    process.exit(1);
  }

  // check if there's anything to commit
  const status = await stdout(["git", "status", "--porcelain"], { cwd: DOTFILES });
  if (!status) {
    log(sym.check, pc.dim("No changes to commit"));
  } else {
    if (!(await run(["git", "commit", "-m", msg], { cwd: DOTFILES }))) {
      error("git commit failed");
      process.exit(1);
    }
    success(`Committed: ${msg}`);
  }

  // get short hash
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

async function genSwitch(opts: { message?: string }) {
  const explicit = opts.message ?? undefined;

  // stage first so claude can see the diff
  await run(["git", "add", "-A"], { cwd: DOTFILES });
  const msg = await commitMessage(explicit);
  const hash = await gitCommit(msg);
  const label = sanitizeLabel(`${hash}-${msg}`);
  await switchConfig(label);
}

export default function register(program: Command) {
  const gen = program
    .command("gen")
    .description("NixOS generation management")
    .option("-m, --message <msg>", "Commit message (auto-generated if omitted)")
    .action(genSwitch);

  gen
    .command("switch")
    .description("Rebuild and switch NixOS configuration")
    .option("-m, --message <msg>", "Commit message (auto-generated if omitted)")
    .action(genSwitch);

  gen
    .command("update")
    .description("Update flake inputs and switch")
    .option("-m, --message <msg>", "Commit message (auto-generated if omitted)")
    .action(async (opts: { message?: string }) => {
      if (!(await run(["sudo", "nix", "flake", "update"], { cwd: DOTFILES }))) {
        error("Flake update failed");
        process.exit(1);
      }
      await genSwitch(opts);
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
        source: (input) => {
          const term = input?.toLowerCase() ?? "";
          return gens
            .filter((g) => !term || g.id.includes(term) || g.date.includes(term))
            .reverse()
            .map((g) => ({
              name: `${g.id}  ${g.date}${g.current ? pc.green(" (current)") : ""}`,
              value: g.id,
            }));
        },
      });
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
