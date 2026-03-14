import type { Command } from "commander";
import pc from "picocolors";
import { readdir, readFile } from "node:fs/promises";
import { join } from "node:path";
import { APP_DIRS, sym, log, error } from "../utils.ts";

interface App { id: string; name: string; path: string; exec: string }

export async function findApps(): Promise<App[]> {
  const apps: App[] = [];
  const seen = new Set<string>();

  for (const dir of APP_DIRS) {
    try {
      const entries = await readdir(dir);
      for (const entry of entries) {
        if (!entry.endsWith(".desktop")) continue;
        const id = entry.replace(/\.desktop$/, "");
        if (seen.has(id)) continue;
        seen.add(id);
        const filePath = join(dir, entry);
        const content = await readFile(filePath, "utf-8");
        const lines = content.split("\n");
        const nameLine = lines.find(l => l.startsWith("Name="));
        const execLine = lines.find(l => l.startsWith("Exec="));
        const hidden = lines.some(l => l === "NoDisplay=true");
        if (nameLine && execLine && !hidden) {
          const exec = execLine.slice(5).replace(/%[uUfFdDnNickvm]/g, "").trim();
          apps.push({ id, name: nameLine.slice(5), path: filePath, exec });
        }
      }
    } catch {}
  }

  return apps.sort((a, b) => a.name.localeCompare(b.name));
}

export default function register(program: Command) {
  program
    .command("open [app]")
    .description("Launch an application")
    .action(async (app?: string) => {
      if (!app) {
        const proc = Bun.spawn(["sway-launcher-desktop"], {
          stdout: "inherit",
          stderr: "inherit",
          stdin: "inherit",
        });
        await proc.exited;
      } else {
        const apps = await findApps();
        const lower = app.toLowerCase();
        const match = apps.find(a =>
          a.id.toLowerCase() === lower ||
          a.name.toLowerCase() === lower ||
          a.id.toLowerCase().endsWith(`.${lower}`) ||
          a.name.toLowerCase().startsWith(lower),
        );
        if (match) {
          log(sym.rocket, pc.green(`Launching ${match.name}...`));
          const args = match.exec.split(/\s+/);
          const proc = Bun.spawn(args, {
            stdout: "ignore",
            stderr: "ignore",
          });
          proc.unref();
        } else {
          error(`App '${app}' not found`);
          process.exit(1);
        }
      }
    });
}
