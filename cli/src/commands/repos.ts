import type { Command } from "commander";
import pc from "picocolors";
import { readdir, stat } from "node:fs/promises";
import { join } from "node:path";
import { REPOS, sym, log, error } from "../utils.ts";

async function isGitRepo(path: string): Promise<boolean> {
  try {
    const gitDir = await stat(join(path, ".git"));
    return gitDir.isDirectory();
  } catch {
    return false;
  }
}

export async function findRepos(): Promise<{ name: string; path: string }[]> {
  const repos: { name: string; path: string }[] = [];
  const entries = await readdir(REPOS, { withFileTypes: true });

  for (const entry of entries) {
    if (!entry.isDirectory()) continue;
    const fullPath = join(REPOS, entry.name);

    if (await isGitRepo(fullPath)) {
      repos.push({ name: entry.name, path: fullPath });
    } else {
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

export default function register(program: Command) {
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
}
