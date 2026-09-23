---
status: open
title: The vitro module is dead
---

## Problem

`modules/vitro.nix` configures the vitro client with a single host,
amoeba, by IP. The module is commented out of `flake.nix`, the `vitro`
input is commented out, vitro was absorbed into cella and deleted from
Codeberg, and amoeba no longer exists. The file only misleads a reader
(and an agent) into thinking the laptop has a vitro client.

## Done when

`modules/vitro.nix` and the commented `vitro` lines in `flake.nix` are
removed.
