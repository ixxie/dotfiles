import type { Command } from "commander";
import pc from "picocolors";
import { mkdir } from "node:fs/promises";
import { HOME, sym, log, success, error, run } from "../utils.ts";

const SNIP_PICS = `${HOME}/Pictures/snips`;
const SNIP_VIDS = `${HOME}/Videos/snips`;

function timestamp() {
  return new Date().toISOString().replace(/[:.]/g, "-").slice(0, 19);
}

async function ensureDir(path: string) {
  await mkdir(path, { recursive: true });
}

async function slurpRegion(): Promise<string | null> {
  const proc = Bun.spawn(["slurp"], { stdout: "pipe", stderr: "pipe" });
  const code = await proc.exited;
  if (code !== 0) return null;
  return (await new Response(proc.stdout).text()).trim();
}

export default function register(program: Command) {
  const snip = program.command("snip").description("Screenshots and screen recording");

  snip
    .command("region", { isDefault: true })
    .description("Screenshot a selected region")
    .action(async () => {
      await ensureDir(SNIP_PICS);
      const region = await slurpRegion();
      if (!region) {
        error("Selection cancelled");
        process.exit(1);
      }
      const out = `${SNIP_PICS}/${timestamp()}.png`;
      if (await run(["grim", "-g", region, out])) {
        const cat = Bun.spawn(["cat", out], { stdout: "pipe" });
        const copy = Bun.spawn(["wl-copy", "-t", "image/png"], { stdin: cat.stdout });
        await copy.exited;
        success(`Saved & copied ${out}`);
      } else {
        error("Screenshot failed");
        process.exit(1);
      }
    });

  snip
    .command("screen")
    .description("Screenshot the entire screen")
    .action(async () => {
      await ensureDir(SNIP_PICS);
      const out = `${SNIP_PICS}/${timestamp()}.png`;
      if (await run(["grim", out])) {
        success(`Saved ${out}`);
      } else {
        error("Screenshot failed");
        process.exit(1);
      }
    });

  snip
    .command("rec")
    .description("Record the screen")
    .option("-r, --region", "Record a selected region")
    .option("-a, --audio", "Include audio")
    .action(async (opts) => {
      await ensureDir(SNIP_VIDS);
      const out = `${SNIP_VIDS}/${timestamp()}.mp4`;
      const args = ["wl-screenrec", "-f", out];

      if (opts.region) {
        const region = await slurpRegion();
        if (!region) {
          error("Selection cancelled");
          process.exit(1);
        }
        args.push("-g", region);
      }

      if (opts.audio) {
        args.push("--audio");
      }

      log(sym.record, pc.red("Recording... press Ctrl+C to stop"));
      const proc = Bun.spawn(args, { stdout: "inherit", stderr: "inherit" });

      process.on("SIGINT", () => {
        proc.kill("SIGINT");
      });

      const code = await proc.exited;
      if (code === 0 || code === null) {
        success(`Saved ${out}`);
      } else {
        error("Recording failed");
        process.exit(1);
      }
    });
}
