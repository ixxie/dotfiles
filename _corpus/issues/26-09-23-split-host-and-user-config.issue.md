---
status: open
title: Split the host config from the user config
assignee: ixxie
---

## Problem

The operator's stated intent is that user-level dotfiles (the
home-manager half) live in `~/config`, and host configuration lives with
the hosts, not in the home. Today this repository is both: the NixOS
system of contingent and the home of `ixxie`, mixed within files by
design (see [flat modules by concern](corpus:decision/25-03-04-flat-modules-by-concern)
and the last section of [architecture](corpus:article/architecture)).

What mixes today:

- **Host only:** `device.nix`, `hardware.nix`, `system.nix`, most of
  `nix.nix`, `modules/tailscale.nix`, `modules/restic-backup.nix`,
  `modules/torrent.nix` (namespace, WireGuard, transmission), the greeter,
  the docker, printing and swap settings.
- **User only:** `modules/helix.nix`, `modules/ghostty.nix` (apart from
  terminal-exec), `modules/git.nix`, `modules/agents/` (apart from Codex's
  `/etc` file), most of `modules/fish.nix` and `modules/yazi.nix`.
- **Both in one file:** `user.nix`, `theme.nix` (system fonts, user GTK
  and cursor), `modules/niri.nix` (package, portals, overlays vs. the
  niri config), `modules/media.nix`, `modules/proton.nix`,
  `modules/voyager/`, `lib/secret.nix` (sops declaration vs. shell
  exports), and the package lists that install user tools system-wide.

Open questions for the split: whether the user half becomes a standalone
home-manager flake (applied without root, reusable on another machine)
or stays a NixOS module imported from `~/config`; where `yo` lives; how
`secretEnv` works for a standalone home (sops-nix has a home-manager
module); and where contingent's host config goes.

## Done when

The user half builds and applies on its own from `~/config`, contingent's
host config lives with the other hosts, and this repository is retired or
reduced to one of the two.
