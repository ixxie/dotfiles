---
status: accepted
title: The greeter reads its sessions from the closure
---

Recorded from `cd7e802` (2026-08-14), after tuigreet replaced SDDM on
2026-02-28 (`d89a540`).

## Context

After a rebuild and a garbage collection, login stopped at tuigreet's "no
command defined", with no session to pick; only an older generation still
booted to the desktop. tuigreet ran with `--remember-session` but no
`--sessions`, so it looked for session files in `/usr/share`, which is
empty on NixOS. Login had only ever worked because the remembered session
was an absolute store path to niri's session file. A nixpkgs bump rebuilt
niri, the GC removed the old store path, and the remembered path dangled.

## Decision

`modules/greeter.nix` passes tuigreet
`--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions`,
the aggregated session directory of the running system, which is part of
its closure and so survives GC, and `--cmd niri-session` as the command
to run when no session is chosen or found.

## Consequences

- The session list is rebuilt from the current system on every boot, so
  a moved niri no longer strands login.
- `--remember-session` still caches a path; the fallback covers it, but
  the watch item stays open
  ([greeter remembered session](corpus:ticket/26-09-23-greeter-remembered-session-still-cached)).
- The general rule for this config: nothing at boot may depend on a
  remembered store path.
