import type { Command } from "commander";
import { rm } from "node:fs/promises";
import { HOME, sym, log, success, error, run } from "../utils.ts";

const DISCORD_DIR = `${HOME}/.config/discord`;

const CACHE_DIRS = [
  "Cache",
  "Code Cache",
  "GPUCache",
  "DawnGraphiteCache",
  "DawnWebGPUCache",
];

export default function register(program: Command) {
  const cmd = program
    .command("discord")
    .description("Discord management");

  cmd
    .command("purge")
    .description("Kill Discord and clear its caches")
    .action(async () => {
      log(sym.broom, "Killing Discord...");
      await run(["pkill", "-9", "-f", "discord"], { silent: true });

      log(sym.broom, "Clearing caches...");
      for (const dir of CACHE_DIRS) {
        try {
          await rm(`${DISCORD_DIR}/${dir}`, { recursive: true, force: true });
        } catch {}
      }

      success("Discord caches purged. Relaunch when ready.");
    });
}
