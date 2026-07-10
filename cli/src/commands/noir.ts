import type { Command } from "commander";
import { existsSync } from "node:fs";
import net from "node:net";
import { sym, log, success, warn, error, run } from "../utils.ts";

const RUNTIME = process.env.XDG_RUNTIME_DIR ?? `/run/user/${process.getuid?.() ?? 1000}`;
const SOCKET = `${RUNTIME}/mpv-celluloid.sock`;

const DCONF_PATH = "/io/github/celluloid-player/celluloid/mpv-options";
const NOIR_FILTER = "lavfi=[hue=s=0]";
const IPC_OPT = `--input-ipc-server=${SOCKET}`;
const NOIR_OPT = `--vf=${NOIR_FILTER}`;

async function readOpts(): Promise<string> {
  const proc = Bun.spawn(["dconf", "read", DCONF_PATH], { stdout: "pipe", stderr: "pipe" });
  await proc.exited;
  const out = (await new Response(proc.stdout).text()).trim();
  const m = out.match(/^'(.*)'$/s);
  return m ? m[1] : "";
}

async function writeOpts(value: string): Promise<void> {
  await run(["dconf", "write", DCONF_PATH, `'${value}'`], { silent: true });
}

function compose(on: boolean, existing: string): string {
  const parts = existing
    .split(/\s+/)
    .filter(p => p && !p.startsWith("--input-ipc-server=") && !p.startsWith("--vf="));
  parts.push(IPC_OPT);
  if (on) parts.push(NOIR_OPT);
  return parts.join(" ");
}

function isOn(opts: string): boolean {
  return opts.includes(NOIR_FILTER);
}

async function ipcSend(cmd: object): Promise<boolean> {
  if (!existsSync(SOCKET)) return false;
  return new Promise<boolean>((resolve) => {
    const client = net.createConnection(SOCKET);
    let done = false;
    const finish = (ok: boolean) => {
      if (done) return;
      done = true;
      try { client.end(); } catch {}
      resolve(ok);
    };
    client.on("connect", () => {
      client.write(JSON.stringify(cmd) + "\n");
      setTimeout(() => finish(true), 150);
    });
    client.on("error", () => finish(false));
  });
}

async function apply(on: boolean): Promise<boolean> {
  return ipcSend({
    command: ["set_property", "vf", on ? NOIR_FILTER : ""],
  });
}

export default function register(program: Command) {
  program
    .command("noir [state]")
    .description("Toggle Celluloid into black-and-white (state: on|off|status)")
    .action(async (state?: string) => {
      const opts = await readOpts();
      const current = isOn(opts);
      let target: boolean;

      switch ((state ?? "").toLowerCase()) {
        case "":
        case "toggle":
          target = !current;
          break;
        case "on":
          target = true;
          break;
        case "off":
          target = false;
          break;
        case "status":
          log(sym.info, current ? "Noir is on 🎞️" : "Noir is off 🌈");
          return;
        default:
          error(`Unknown state '${state}'. Use on, off, toggle, or status.`);
          process.exit(1);
      }

      await writeOpts(compose(target, opts));

      const live = await apply(target);

      if (target) {
        success("Noir on — Celluloid is monochrome 🎞️");
      } else {
        success("Noir off — colors restored 🌈");
      }

      if (!live) {
        warn("No running Celluloid (or no video loaded yet). Open a video; future toggles will hot-apply via IPC.");
      }
    });
}
