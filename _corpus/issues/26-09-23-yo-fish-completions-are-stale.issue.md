---
status: open
title: yo's fish completions are stale
---

## Problem

The completions offer commands that no longer exist and miss ones that
do. `cli/src/commands/completions.ts` lists `sys`, `repos`, `cd`, `tree`,
`open`, `noir`, `completions` and completes `sys` with `switch`, `update`,
`gc`; `modules/fish.nix` also wires a `cell` subcommand. There is no
`sys` or `cell` command. `gen` (with `switch`, `commit`, `list`, `back`,
`pick`, `gc`, `tui`), `media` and `discord` are not offered.

## Done when

The completion list is derived from commander's registered commands (so
it cannot drift again), and `fish.nix` completes the subcommands that
exist.
