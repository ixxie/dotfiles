---
status: accepted
title: home-manager runs as a NixOS module
---

Recorded from `08d6f77` ("put home-manager into nixos config", 2022-11-26).

## Context

The user half of the config had been managed by home-manager since 2017,
first as a git submodule with an `install.sh` that symlinked the rest, then
through a channel (`<home-manager/nixos>` style imports came and went). A
separate `home-manager switch` meant two apply steps, two generations to
keep in step, and a home that could drift from the system it ran on.

## Decision

home-manager is imported as a NixOS module (`inputs.home-manager.nixosModules.home-manager`
in `user.nix`), and the user's configuration is
`home-manager.users.ixxie`. One `nixos-rebuild switch` applies both
halves; one generation holds both.

## Consequences

- Any NixOS module can set user options next to system ones, which is why
  most files under `modules/` do both
  (see [flat modules by concern](corpus:decision/25-03-04-flat-modules-by-concern)).
- The user half cannot be applied without root, and cannot be reused on a
  machine that is not this NixOS host. That is the cost the
  [host/user split](corpus:ticket/26-09-23-split-host-and-user-config)
  wants to undo.
- home-manager backs up clobbered files with the `backup` extension
  instead of failing the switch.
