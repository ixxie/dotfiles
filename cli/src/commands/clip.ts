import type { Command } from "commander";
import { search } from "../lib/tui.ts";
import { success, error } from "../utils.ts";
import { truncate } from "../lib/interactive.ts";

async function stdout(cmd: string[]): Promise<string> {
  const proc = Bun.spawn(cmd, { stdout: "pipe" });
  return (await new Response(proc.stdout).text()).trim();
}

async function clipEntries(): Promise<string[]> {
  const out = await stdout(["cliphist", "list"]);
  if (!out) return [];
  return out.split("\n");
}

async function decodeAndCopy(entry: string) {
  const decode = Bun.spawn(["cliphist", "decode"], {
    stdin: "pipe",
    stdout: "pipe",
  });
  decode.stdin.write(entry);
  decode.stdin.end();
  const copy = Bun.spawn(["wl-copy"], { stdin: decode.stdout });
  await copy.exited;
}

export default function register(program: Command) {
  const clip = program.command("clip").description("Clipboard operations");

  clip
    .command("list")
    .description("List clipboard history")
    .option("-n, --lines <n>", "Number of entries", "20")
    .action(async (opts) => {
      const out = await stdout(["cliphist", "list"]);
      if (!out) {
        error("Clipboard history is empty");
        return;
      }
      const lines = out.split("\n").slice(0, parseInt(opts.lines));
      console.log(lines.join("\n"));
    });

  clip
    .command("copy")
    .description("Copy text to clipboard")
    .argument("<text...>", "Text to copy")
    .action(async (text: string[]) => {
      const input = text.join(" ");
      const proc = Bun.spawn(["wl-copy"], { stdin: "pipe" });
      proc.stdin.write(input);
      proc.stdin.end();
      await proc.exited;
      success("Copied to clipboard");
    });

  clip
    .command("paste")
    .description("Paste clipboard contents to stdout")
    .action(async () => {
      const out = await stdout(["wl-paste"]);
      console.log(out);
    });

  clip
    .command("pick")
    .description("Pick from clipboard history (interactive)")
    .action(async () => {
      const entries = await clipEntries();
      if (!entries.length) {
        error("Clipboard history is empty");
        return;
      }
      const cols = process.stdout.columns ?? 80;
      const selected = await search({
        message: "Clipboard history",
        source: (term) => {
          const q = term.toLowerCase();
          return entries
            .filter((e) => !q || e.toLowerCase().includes(q))
            .map((e) => ({ name: truncate(e, cols - 4), value: e }));
        },
      });
      if (!selected) return;
      await decodeAndCopy(selected);
      success("Copied from history");
    });

  clip
    .command("clear")
    .description("Clear clipboard history")
    .action(async () => {
      const proc = Bun.spawn(["cliphist", "wipe"]);
      if ((await proc.exited) === 0) {
        success("Clipboard history cleared");
      } else {
        error("Failed to clear history");
      }
    });
}
