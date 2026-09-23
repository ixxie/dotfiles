---
status: accepted
title: Flat modules, one per concern
---

Recorded from `f11dbbc` ("The great flattening", 2025-03-04).

## Context

The tree had grown `programs/`, `system/` and `user/` directories with
`default.nix` aggregators in each. A single concern (say, the desktop)
was spread over three places, one per layer, and finding where something
was set meant knowing which layer set it.

## Decision

One flat `modules/` directory with one file per concern (`niri.nix`,
`fish.nix`, `media.nix`, …), each a NixOS module that sets whatever it
needs, system options and `home-manager.users.ixxie` options alike. The
host basics sit at the root (`device.nix`, `hardware.nix`, `system.nix`,
`nix.nix`, `theme.nix`, `user.nix`). `flake.nix` lists every module
explicitly, grouped by comments; there is no auto-import. A concern that
outgrows a file becomes a directory (`modules/agents/`,
`modules/voyager/`).

## Consequences

- Deleting a feature is deleting a file and a line in `flake.nix`.
- Host and user config are mixed within files. That is the point of the
  layout, and also what makes the
  [host/user split](corpus:ticket/26-09-23-split-host-and-user-config) a
  real refactor rather than a move.
