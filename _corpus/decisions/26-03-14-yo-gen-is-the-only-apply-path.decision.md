---
status: accepted
title: yo gen is the only apply path
---

Recorded from the `yo gen` work of 2026-03-14 to 2026-03-17 (`a4e9d47`
through `c4690a5`) and the standing rule in the shared agent instructions
("always use `yo gen switch` instead of `sudo nixos-rebuild switch`").

## Context

A bare `nixos-rebuild switch` leaves no label on the generation, forgets
to update local inputs, and needs the flake path and `--impure` spelled
out each time. With agents editing the config, an agent could also switch
the laptop from under the person using it.

## Decision

The config is applied with `yo gen switch` or `yo gen commit`, run by the
operator. `yo` sets the generation label, updates local inputs, passes
`--impure` and the flake path, keeps a build history, and offers rollback
(`back`, `pick`) and pruning (`gc`) next to it. Agents do not apply: they
edit, evaluate, and hand the switch to the operator. Agent sessions on the
laptop are not permitted `sudo`, `yo` or `nixos-rebuild`.

## Consequences

- Every applied change passes a human at the keyboard, including an
  agent's.
- `wheel` needs no password for sudo (`system.nix`), so the rule rests on
  the agents' own permission settings, not on the system.
- Work that needs a switch (a new secret, a backup retarget) waits for
  the operator, and agents must say so rather than work around it.
- `yo`'s behavior is part of the apply path: its `git add -A` and its
  local-input detection matter
  ([stages the whole tree](corpus:issue/26-09-23-yo-gen-switch-stages-the-whole-tree),
  [misses git+file inputs](corpus:issue/26-09-23-yo-misses-git-file-local-inputs)).
- See [applying changes](corpus:guide/applying).
