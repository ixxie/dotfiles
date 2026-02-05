#!/usr/bin/env bun
import { program } from "commander";
import pc from "picocolors";
import { readdir, stat } from "node:fs/promises";
import { join } from "node:path";

const HOME = process.env.HOME ?? "/home/ixxie";
const DOTFILES = `${HOME}/repos/dotfiles`;
const FLAKE = `${DOTFILES}#contingent`;
const REPOS = `${HOME}/repos`;
const GC_KEEP_DAYS = "7d";

const sym = {
  check: "✓",
  cross: "✗",
  gear: "⚙",
  rocket: "🚀",
  broom: "🧹",
  refresh: "🔄",
  folder: "📂",
};

function log(symbol: string, msg: string) {
  console.log(`${pc.cyan(symbol)} ${msg}`);
}

function success(msg: string) {
  console.log(`${pc.green(sym.check)} ${msg}`);
}

function error(msg: string) {
  console.log(`${pc.red(sym.cross)} ${msg}`);
}

async function run(cmd: string[], opts?: { cwd?: string }) {
  const proc = Bun.spawn(cmd, {
    cwd: opts?.cwd ?? process.cwd(),
    stdout: "inherit",
    stderr: "inherit",
  });
  return (await proc.exited) === 0;
}

async function isGitRepo(path: string): Promise<boolean> {
  try {
    const gitDir = await stat(join(path, ".git"));
    return gitDir.isDirectory();
  } catch {
    return false;
  }
}

async function findRepos(): Promise<{ name: string; path: string }[]> {
  const repos: { name: string; path: string }[] = [];
  const entries = await readdir(REPOS, { withFileTypes: true });

  for (const entry of entries) {
    if (!entry.isDirectory()) continue;
    const fullPath = join(REPOS, entry.name);

    if (await isGitRepo(fullPath)) {
      repos.push({ name: entry.name, path: fullPath });
    } else {
      // check one level deeper
      try {
        const subEntries = await readdir(fullPath, { withFileTypes: true });
        for (const sub of subEntries) {
          if (!sub.isDirectory()) continue;
          const subPath = join(fullPath, sub.name);
          if (await isGitRepo(subPath)) {
            repos.push({ name: `${entry.name}/${sub.name}`, path: subPath });
          }
        }
      } catch {}
    }
  }

  return repos.sort((a, b) => a.name.localeCompare(b.name));
}

// Main program
program
  .name("yo")
  .description(pc.bold("System management CLI"))
  .version("0.1.0");

program
  .command("switch")
  .description("Rebuild and switch NixOS configuration")
  .option("-u, --update", "Update flake inputs first")
  .action(async (opts) => {
    if (opts.update) {
      log(sym.refresh, pc.yellow("Updating flake inputs..."));
      if (!(await run(["sudo", "nix", "flake", "update"], { cwd: DOTFILES }))) {
        error("Failed to update flake");
        process.exit(1);
      }
    }

    log(sym.rocket, pc.magenta("Building and switching configuration..."));
    if (await run(["sudo", "nixos-rebuild", "switch", "--flake", FLAKE])) {
      success("System switched!");
    } else {
      error("Switch failed");
      process.exit(1);
    }
  });

program
  .command("update")
  .description("Update flake inputs")
  .action(async () => {
    log(sym.refresh, pc.yellow("Updating flake inputs..."));
    if (await run(["sudo", "nix", "flake", "update"], { cwd: DOTFILES })) {
      success("Flake updated!");
    } else {
      error("Update failed");
      process.exit(1);
    }
  });

program
  .command("gc")
  .description("Garbage collect old generations")
  .action(async () => {
    log(sym.broom, pc.yellow("Cleaning up old generations..."));
    if (
      !(await run(["sudo", "nix-collect-garbage", "--delete-older-than", GC_KEEP_DAYS]))
    ) {
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

program
  .command("repos")
  .description("List repos in ~/repos")
  .action(async () => {
    const repos = await findRepos();

    const rootRepos = repos.filter((r) => !r.name.includes("/"));
    const grouped = new Map<string, typeof repos>();

    for (const r of repos) {
      if (r.name.includes("/")) {
        const [group] = r.name.split("/");
        const list = grouped.get(group) ?? [];
        list.push(r);
        grouped.set(group, list);
      }
    }

    if (rootRepos.length > 0) {
      console.log(pc.cyan("\nrepos/"));
      for (const r of rootRepos) {
        console.log(pc.white(`  ${r.name}`));
      }
    }

    for (const [group, groupRepos] of grouped) {
      console.log(pc.cyan(`\n${group}/`));
      for (const r of groupRepos) {
        const name = r.name.split("/")[1];
        console.log(pc.white(`  ${name}`));
      }
    }
    console.log();
  });

program
  .command("cd <name>")
  .description("Open a repo in a new terminal")
  .action(async (name: string) => {
    const repos = await findRepos();

    const match = repos.find(
      (r) => r.name === name || r.name.endsWith(`/${name}`),
    );

    if (match) {
      log(sym.folder, pc.green(`Opening ${match.name}...`));
      const proc = Bun.spawn(["ghostty", `--working-directory=${match.path}`], {
        stdout: "ignore",
        stderr: "ignore",
      });
      proc.unref();
    } else {
      error(`Repo '${name}' not found`);
      process.exit(1);
    }
  });

program
  .command("tree")
  .description("Tree with gitignore and dirs first")
  .allowUnknownOption()
  .allowExcessArguments()
  .action(async (_, cmd) => {
    const extra = cmd.args.length ? cmd.args : ["."];
    const args = [
      "eza", "--tree", "--icons",
      "--git-ignore", "--group-directories-first",
      ...extra,
    ];
    await run(args);
  });

// Completions
program
  .command("completions")
  .description("Generate fish completions")
  .argument("[command]", "Command to complete")
  .argument("[current]", "Current word being typed")
  .action(async (command?: string, current?: string) => {
    if (command === "cd") {
      const repos = await findRepos();
      const matches = repos.filter((r) => {
        const name = r.name.includes("/") ? r.name.split("/")[1] : r.name;
        return !current || name.startsWith(current);
      });
      for (const r of matches) {
        const name = r.name.includes("/") ? r.name.split("/")[1] : r.name;
        console.log(name);
      }
    } else {
      const commands = ["switch", "update", "gc", "repos", "cd", "tree", "completions"];
      for (const cmd of commands) {
        if (!current || cmd.startsWith(current)) {
          console.log(cmd);
        }
      }
    }
  });

program.parse();
