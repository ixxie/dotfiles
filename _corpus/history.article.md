---
title: History
---

# History

578 commits between February 2016 and September 2026, in bursts. The
repository began as someone else's dotfiles, became a NixOS configuration,
went quiet for years at a time, and since early 2026 has been worked on
steadily, lately with coding agents as co-authors.

| period | commits | shape |
|---|---|---|
| 2016-02 → 2017-09 | ~210 | Kevin Sidarous's (llgtr) macOS/Linux dotfiles, with Matan's NixOS config merged in |
| 2017-09 → 2018-09 | ~110 | Matan's own: home-manager as a submodule, emacs, NixOps |
| 2019 → 2020-09 | ~40 | refactors; home and system merged; xmonad, fish |
| 2022-03 → 2023-07 | 9 | home-manager inside NixOS; the flake |
| 2024-10 → 2025-11 | ~45 | contingent; the great flattening; niri |
| 2026-01 → 2026-09 | ~160 | `yo`, sops, cyberdeck, agents, backup, hardening |

## Borrowed beginnings (2016-02 → 2017-09)

The first commit, `1ce3d1b` on 2016-02-23, is Kevin Sidarous's "Preliminary
version": bash, OS X defaults scripts, later tmux, vim with Vundle, openbox,
lemonbar then polybar, zsh and emacs. Kevin committed as Kevin, Kevin S,
Kevin Sidarous and llgtr.

Matan's history joins on 2016-12-29 with "Rebuilt Flux Script Tool" and a
NixOS configuration under the name *fluxstack* (a GitHub
`fluxcraft/fluxstack` remote is merged in January 2017): templated
`configuration.nix`, a GNOME module, an install script, the upgrade to
NixOS 17.03. The two lines run side by side until 2017-09-18, when Matan
rewrote the README "to make it my own" and the next day moved the licence
to his name.

## Matan's dotfiles (2017-09 → 2018-09)

On 2017-09-19 the first `home.nix` lands, with home-manager as a git
submodule (`d697801`) and an `install.sh` that symlinks the rest. A year of
emacs tuning, tmux, a Jupyterhub module, Haskell and Python tooling, Nix 2,
and NixOps deployments of servers (`codex`, the `telex` drone). In
September 2018 the home-manager submodule goes (`80456d1`), emacs is
replaced by neovim (`cf2cd13`), and the modules are reorganized.

## Refactors (2019 → 2020-09)

Sparse. A module-structure refactor merged as the repository's first two
pull requests (2020-04). On 2020-07-18 the home and system dotfiles are
merged into one tree (`37e6037`), xmonad with picom returns, git and
bluetooth config are converted to Nix, and fish becomes the login shell
(`8be4585`). Plasma is tried for two days in September 2020.

## Inside NixOS, then a flake (2022-03 → 2023-07)

After a gap of eighteen months, "put home-manager into nixos config"
(`08d6f77`, 2022-11-26) makes home-manager a NixOS module, which it has
been since; see
[home-manager as a NixOS module](corpus:decision/22-11-26-home-manager-as-a-nixos-module).
On 2023-03-28 the configuration moves to a flake (`ce02e43`), with fish
swapped for bash and GDM for LightDM after the migration broke them; see
[one flake, one host](corpus:decision/23-03-28-one-flake-one-host).

## contingent (2024-10 → 2025-11)

"Resurection: contingent framework 13 laptop" (`b951f6e`, 2024-10-15)
retargets the flake at the current laptop. Commits are named by date
("19/02/25", "31/03/25") for a while. "The great flattening" (`f11dbbc`,
2025-03-04) collapses `programs/`, `system/` and `user/` into a flat
`modules/` directory and root-level `system.nix` and `user.nix`; see
[flat modules by concern](corpus:decision/25-03-04-flat-modules-by-concern).
Stylix arrives for theming (2025-03), ghostty replaces alacritty next to
helix and nushell, and niri becomes the compositor on 2025-05-13
([niri is the compositor](corpus:decision/25-05-13-niri-is-the-compositor)),
first with waybar, then from 2025-09-13 with the Noctalia shell.

From 2025-09-07 commits follow the conventional `type(scope):` form, and the
first Claude Code module lands (`0cd7b71`, 2025-09-08).

## The busy year (2026-01 → 2026-09)

**January to April: tooling.** The `yo` CLI appears on 2026-01-20 (`d7bba0d`,
alongside a return to fish), then grows fast in March: `gen` with labels, a
dashboard, AI-planned commits (`e44e5cd`), and `media`. On 2026-03-16 it
stops being a packaged derivation and runs from source with Bun
(`aa2b498`); it was renamed from `org` to `yo` on 2026-05-11. sops-nix and
`secrets.yaml` arrive on 2026-02-16 (`fd0c218`), and on 2026-02-28 the
secrets move into the modules that use them (`fc6dde5`). The same day
tuigreet replaces SDDM and base16.nix replaces Stylix. cyberdeck, the
operator's own bar, lands on 2026-03-22 and replaces Noctalia on 2026-04-03
(`9b94ec3`), the day the base16 scheme is inlined as plain data
(`826d4cc`). `lib/secret.nix` and its `secretEnv` option appear on
2026-03-29. A cella module comes and goes (2026-03-21 to 2026-05-11, replaced
by vitro, itself now disabled).

**May to July: agents and ops.** On 2026-05-21 a single large commit
(`50a4c51`, titled "fix readme") creates `modules/agents/` with a shared
`AGENTS.md` and skills, the two Claude Code profiles, and tailscale. The
restic backup starts on 2026-06-02 as a stop-gap to amoeba, the old Hetzner
dev host (`01f603c`). On 2026-07-10 the repository moves to
`~/repos/lab/dotfiles` (`68c5db5`), gains the Proton Mail bridge, and
Claude settings become a writable seeded copy (`42ac515`).

**August and September: hardening.** The fixes that matter most:

- `cd7e802` (2026-08-14): the greeter stranded login at "no command
  defined" after a rebuild and GC; it now reads sessions from the closure
  ([decision](corpus:decision/26-08-14-greeter-sessions-come-from-the-closure)).
- `36718be` (2026-08-14): systemd-boot capped at 10 generations, because
  the full 512M ESP had started failing switches.
- `0e5c8a0` (2026-08-14): bluetooth profile policy handed to cyberdeck's
  new pipewire backend, ending headset connect/disconnect loops
  ([decision](corpus:decision/26-08-14-cyberdeck-owns-bluetooth-profiles)).
- `e9529f8` (2026-08-14): a `libdisplay-info_0_2` overlay keeps niri
  building after nixpkgs dropped the alias.
- `ac11676` (2026-09-04): the Claude Code profile follows the working
  directory, and the settings seed merges rather than replaces
  ([decision](corpus:decision/26-09-04-claude-settings-merge-and-follow-the-work-tree)).
- `7583b95` (2026-09-04): screencast through the gnome portal, since the
  wlr portal froze Discord shares on the first frame.
- `f7ea779` (2026-09-23): the Hetzner token exported as `HCLOUD_TOKEN`
  for agents.
- `d58e8f9`, `55a338c`, `7e589ee` (2026-09-23): the backup, failing
  silently since amoeba was destroyed, retargeted to bacillus by its public
  name, with client work excluded and first-run initialization
  ([decision](corpus:decision/26-09-23-backup-to-bacillus-by-public-name)).

## Authors

Matan Bendix Shenhav (as "Matan Bendix Shenhav" and "Matan Shenhav") wrote
419 of the commits, Kevin Sidarous (also as llgtr) the other 159. Since February
2026 many commits carry a `Co-Authored-By: Claude …` trailer, and a
recurring "chore: remaining changes" is the signature of `yo gen commit`,
which commits whatever its plan left over.
