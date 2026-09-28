---
status: accepted
title: Contingent's config lives whole in ~/config
---

Ruled by the operator on 2026-09-28.

## Context

The home layout put user-level dotfiles in `~/config` and host config
"in cella hosts/, never in ~", and
[splitting host and user config](corpus:ticket/26-09-23-split-host-and-user-config)
planned for this repository to be carved in two along that line. The
split landed in place (`host/` and `home/`, merged in `ae94de2`), but the
second half of the plan had nowhere sensible to go: contingent is the
operator's personal laptop, and cella is a FOSS project. A personal
machine's hardware, secrets and services have no business in a public
framework's `hosts/`.

## Decision

This repository is contingent's config, host and user alike, and it lives
at `~/config`. The `host/` and `home/` directories stay as the internal
split; neither half moves out. The repository keeps its flake,
`nixosConfigurations.contingent`, and home-manager stays a NixOS module
(see [home-manager as a NixOS module](corpus:decision/22-11-26-home-manager-as-a-nixos-module)).

## Consequences

- `yo`, `$DOTFILES` and the `yo` wrapper point at `~/config`; until the
  switch that carries that, `~/projects/workshop/dotfiles` is a symlink
  to it.
- The repository is no longer a member of the workshop group.
- A standalone home-manager flake, applied without root and reusable on
  another machine, stays possible as a later step inside this
  repository; it no longer implies moving the host config anywhere.
