import pc from "picocolors";

export const HOME = process.env.HOME ?? "/home/ixxie";
export const DOTFILES = `${HOME}/repos/dotfiles`;
export const FLAKE = `${DOTFILES}#contingent`;
export const REPOS = `${HOME}/repos`;

export const APP_DIRS = [
  "/run/current-system/sw/share/applications",
  `${HOME}/.local/share/applications`,
  `${HOME}/.nix-profile/share/applications`,
];

export const sym = {
  check: "✓",
  cross: "✗",
  gear: "⚙",
  rocket: "🚀",
  broom: "🧹",
  refresh: "🔄",
  folder: "📂",
  camera: "📸",
  record: "🔴",
};

export function log(symbol: string, msg: string) {
  console.log(`${pc.cyan(symbol)} ${msg}`);
}

export function success(msg: string) {
  console.log(`${pc.green(sym.check)} ${msg}`);
}

export function error(msg: string) {
  console.log(`${pc.red(sym.cross)} ${msg}`);
}

export async function run(cmd: string[], opts?: { cwd?: string; silent?: boolean }) {
  const proc = Bun.spawn(cmd, {
    cwd: opts?.cwd ?? process.cwd(),
    stdout: opts?.silent ? "pipe" : "inherit",
    stderr: opts?.silent ? "pipe" : "inherit",
  });
  return (await proc.exited) === 0;
}
