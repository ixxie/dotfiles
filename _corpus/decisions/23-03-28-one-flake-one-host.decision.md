---
status: accepted
title: One flake, one host
---

Recorded from `ce02e43` ("Refactor: move to flake config", 2023-03-28) and
`b951f6e` (the retarget to contingent, 2024-10-15).

## Context

The config had been a channel-based `configuration.nix` since 2016, with
inputs pinned by whatever the channels held on the day. Machines came and
went (meso, a Dell XPS 13, then the Framework).

## Decision

The repository is a Nix flake whose only system output is
`nixosConfigurations.contingent`. Every input is pinned in `flake.lock`
and, wherever the input allows it, follows the one `nixpkgs`
(nixos-unstable). Local sibling repositories (cyberdeck, janeway) are
flake inputs by `git+file:` URL rather than overlays or copies.

## Consequences

- A rebuild is reproducible from the lock; updating is an explicit act
  (`yo gen switch -u`, or `nix flake update <input>`).
- A `git+file:` input builds from the sibling's committed tree, not its
  working tree, so a sibling change must be committed and relocked before
  it reaches the system.
- New files must be known to git before the flake can see them.
- The host is named in the flake and in `yo` (`FLAKE = …#contingent`);
  there is no multi-host structure, and none is wanted here: other hosts
  live in their own repositories.
