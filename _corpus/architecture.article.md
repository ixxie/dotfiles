---
title: Architecture
---

# Architecture

How contingent's config is put together, read bottom to top: the machine,
the NixOS system on it, the services, the user's home, and the development
and agent tooling on top. The flake has one output,
`nixosConfigurations.contingent`, and every file below is a NixOS module in
its `modules` list, including the ones that only configure the user.

```strata
title = "contingent, bottom to top"

[palette]
host = "#7a8aa3"
sys  = "#3b6ea5"
svc  = "#2f7f8a"
user = "#3f8a5c"
dev  = "#8a5a9c"

[[layers]]
name = "Hardware"
modules = [
  { id = "device",   label = "device.nix · Framework 13 AMD", icon = "laptop",      color = "host", weight = 2 },
  { id = "hardware", label = "hardware.nix · disks, initrd",  icon = "hard-drives", color = "host" },
]

[[layers]]
name = "NixOS system"
modules = [
  { id = "boot",  label = "system.nix · boot, network", icon = "gear",    color = "sys", weight = 2 },
  { id = "nix",   label = "nix.nix · nix, caches",      icon = "package", color = "sys" },
  { id = "theme", label = "theme.nix · base16",         icon = "layout",  color = "sys" },
]

[[layers]]
name = "Services"
modules = [
  { id = "sops",      label = "sops-nix + secretEnv", icon = "vault",   color = "svc" },
  { id = "tailscale", label = "tailscale",            icon = "network", color = "svc" },
  { id = "restic",    label = "restic → bacillus",    icon = "archive", color = "svc" },
  { id = "greeter",   label = "greetd + tuigreet",    icon = "lock",    color = "svc" },
]

[[layers]]
name = "User (home-manager)"
modules = [
  { id = "shell",   label = "shell · fish, ghostty, yazi", icon = "terminal-window", color = "user" },
  { id = "editor",  label = "editor · helix",              icon = "code",            color = "user" },
  { id = "desktop", label = "desktop · niri + cyberdeck",  icon = "desktop",         color = "user", weight = 2 },
]

[[layers]]
name = "Dev & agents"
modules = [
  { id = "yo",     label = "yo CLI",                           icon = "terminal", color = "dev" },
  { id = "agents", label = "agents · Claude, Codex, OpenCode", icon = "robot",    color = "dev", weight = 2 },
  { id = "ops",    label = "ops · git, hcloud, gandi",         icon = "cloud",    color = "dev" },
]

[[edges]]
from = "device"
to = "boot"

[[edges]]
from = "boot"
to = "greeter"

[[edges]]
from = "greeter"
to = "desktop"
label = "niri-session"

[[edges]]
from = "sops"
to = "shell"
label = "tokens"

[[edges]]
from = "shell"
to = "agents"

[[edges]]
from = "shell"
to = "yo"
```

## Hardware

`device.nix` is the machine: the nixos-hardware profile for the Framework
13 7040 AMD, the `amdgpu` initrd module with `amdgpu.aspm=0` (spurious PME
interrupts on Phoenix), the framework kernel module disabled (an upstream
nixos-hardware issue), firmware updates (fwupd), upower and
power-profiles-daemon, experimental bluetooth, and the ZSA keyboard stack
(zapp, keymapp, udev rules for the Voyager). `hardware.nix` is the file
`nixos-generate-config` wrote: initrd modules, the root and ESP filesystems
by UUID.

## NixOS system

`system.nix` holds the host proper: hostname, NetworkManager with IPv6,
passwordless sudo for `wheel`, the latest kernel, systemd-boot capped at 10
generations (the 512M ESP cannot grow, and filled at about 20), printing,
the timezone and locale, nix-ld, a 64G swapfile and docker. It also imports
sops-nix and points it at `secrets.yaml` and the operator's age key, and it
reads `NIXOS_LABEL` from the environment into the generation label, which
is why the rebuild runs `--impure`.

`nix.nix` configures nix itself: flakes, the binary caches (cache.nixos.org,
niri, nix-community, microvm, pi) and their keys, automatic GC,
`allowUnfree` and `allowBroken`, and the GitHub access token, included into
both the daemon's and the user's `nix.conf` from sops. It installs the nix
tooling (nixfmt, nixos-anywhere, colmena, sops) and direnv with nix-direnv.

`theme.nix` defines the palette once: `config.scheme`, a plain base16
attrset (Everforest Dark Hard) from base16.nix, plus fonts (Monaspace Nerd
Fonts, Twemoji), the cursor, the icon theme and GTK/dconf font settings.
Every themed program reads `config.scheme` rather than carrying its own
colors: fish, helix, ghostty, yazi, tuigreet and the console, cyberdeck,
the Voyager overlay and the Claude Code theme.

`user.nix` creates `ixxie` (fish as login shell; wheel, docker, input,
audio and others) and sets up home-manager as a NixOS module: session
variables (`EDITOR=hx`, `BROWSER=zen`, `TERMINAL=ghostty`), XDG user
directories mapped onto the home's own layout, desktop entries and MIME
defaults.

## Services

- **Secrets.** sops-nix decrypts `secrets.yaml` at activation. Each secret
  is declared by the module that uses it, and `lib/secret.nix` adds the
  `secretEnv` option, which exports chosen secrets as environment variables
  in fish (interactive init) and in POSIX shells (`environment.extraInit`).
  See [managing secrets](corpus:guide/secrets).
- **tailscale** (`modules/tailscale.nix`): a client with `ixxie` as
  operator. Nothing else in the config depends on it; the backup
  deliberately does not.
- **Backup** (`modules/restic-backup.nix`): a daily systemd timer runs
  restic as `ixxie` over SFTP to the personal server, bacillus. See
  [backup](corpus:guide/backup).
- **Greeter** (`modules/greeter.nix`): greetd running tuigreet, themed from
  the scheme, with the session list wired from the system closure and
  `niri-session` as the fallback command.
- **Torrents** (`modules/torrent.nix`): transmission on localhost, plus a
  network namespace with a WireGuard tunnel to ProtonVPN, a tinyproxy
  inside it and a socat forward to it on the host. `yo media` searches
  through that proxy; the proxy address reaches `yo` through
  `~/.config/yo/config.json`.
- **Mail** (`modules/proton.nix`): the Proton Mail bridge as a user service
  and mbsync pulling folders on demand (`proton.sync <folder>`).
- **Audio** (`modules/media.nix`): pipewire with pulse, jack and alsa;
  wireplumber's bluetooth roles trimmed to a2dp and hfp_ag, and its headset
  autoswitch off, because cyberdeck's audio backend owns profile switching.

## User (home-manager)

Most modules configure the user, and most of them do it from NixOS: they set
`home-manager.users.ixxie.*` next to any system options they need.

- **Shell.** `modules/fish.nix` (fish, starship, carapace, eza, bat,
  zoxide, the `yo` wrapper and its completions, base16 fish colors, and the
  `_claude_profile` hook), `modules/ghostty.nix` (terminal, base16 theme,
  default terminal via xdg terminal-exec), `modules/yazi.nix` (file manager,
  and the system file chooser through xdg-desktop-portal-termfilechooser),
  `modules/cli.nix` (command-line packages, including a packaged Vercel CLI
  from `pkgs/vercel.nix`).
- **Editor.** `modules/helix.nix`: helix with language servers and
  formatters per language and a base16 theme generated from the scheme.
- **Desktop.** `modules/niri.nix` runs niri-unstable from niri-flake (built
  locally, with a `libdisplay-info_0_2` overlay until niri-flake catches
  up), its keybindings, outputs and window rules, and the xdg portals
  (gtk by default, gnome for screencast, wlr for screenshots).
  `modules/cyberdeck.nix` enables cyberdeck, the operator's own bar and
  launcher (a sibling repo in the lab), with its modules: workspaces,
  audio, bluetooth, airplane, network, weather, screenshots and more.
  `modules/voyager/` shows the ZSA Voyager's layers as an overlay (from
  janeway), with keymapp running headless under Xvfb for the live layer
  feed.
- **Apps.** Browsers (Zen via its flake, Firefox, Chromium, Tor Browser),
  messaging (Signal, Element, Discord, Cinny, an iamb config), media
  (Spotify, Celluloid), design (Inkscape, GIMP, ImageMagick and friends).

## Dev and agents

- **git** (`modules/git.nix`): identity, aliases, gh and codeberg-cli
  (`berg`, configured for codeberg.org).
- **Agents** (`modules/agents/`): Claude Code, Codex and OpenCode share one
  `AGENTS.md` and one `skills/` directory. Claude Code has two profiles
  built by `mkProfile` in `claude/lib.nix`: personal (`~/.claude`) and
  qualia (`~/.claude-qualia`, the work account), chosen by the working
  directory through fish's `_claude_profile`. Each profile's
  `settings.json` is merged on activation rather than linked, since Claude
  Code and other tools write to it at runtime. Codex reads a system-level
  `/etc/codex/config.toml` for the same reason. The module exports the
  OpenRouter key through `secretEnv`. See
  [one agents module](corpus:decision/26-05-21-one-agents-module-for-every-agent).
- **Ops** (`modules/hetzner.nix`, `modules/gandi.nix`): hcloud and
  nixos-anywhere with `HCLOUD_TOKEN`, and the Gandi API with
  `GANDI_TOKEN` (the Gandi module is staged but not yet committed), so an
  agent can provision without being handed a token.
- `modules/vitro.nix` is kept but commented out of the flake; see
  [the vitro module is dead](corpus:ticket/26-09-23-vitro-module-is-dead).

## The yo CLI

`cli/` is a Bun/TypeScript program on commander. `src/index.ts` registers
one module per command from `src/commands/`; shared pieces live in
`src/lib/` (a small TUI framework, SQLite storage, TMDB/OMDB clients,
transmission RPC, torrent search, a `claude -p` helper) and
`src/utils.ts` (paths: `DOTFILES`, `FLAKE`, and the `run` helper).

| command | what it does |
|---|---|
| `yo gen switch` | stage everything, update local inputs, `nixos-rebuild switch` |
| `yo gen commit` | as above, but first commit via a Claude-written commit plan, and label the generation |
| `yo gen list · back · pick · gc · tui` | generations: list, roll back, switch to one, prune, dashboard |
| `yo repos`, `yo cd <name>` | list `~/repos`, open one in a new terminal |
| `yo open [app]` | launch a desktop app by id |
| `yo tree` | eza tree, gitignore-aware |
| `yo media` | watchlist, ratings, trope exploration and torrents |
| `yo noir [on·off·toggle·status]` | Celluloid in black and white |
| `yo discord purge` | kill Discord and clear its caches |
| `yo completions` | fish completion source |

The wrapper in `modules/fish.nix` runs the source with Bun, so the CLI is
not part of the system closure and its edits need no switch.

## Where host and user mix

The machine and the person are two directories: `host/` (`device.nix`,
`hardware.nix`, `system.nix`, `nix.nix`) and `home/` (`user.nix`,
`theme.nix`, `modules/`), each with a `default.nix` the flake imports.
The line is by file, not by option: `nix.nix` also configures the user's
direnv and `nix.conf`, `theme.nix` sets system fonts beside the user's
GTK theme, and several modules under `home/modules/` (`niri.nix`,
`media.nix`, `greeter.nix`, `torrent.nix`, `restic-backup.nix`) set NixOS
options too. Both halves stay in this repository at `~/config`; see
[contingent lives whole in ~/config](corpus:decision/26-09-28-contingent-lives-whole-in-config).
