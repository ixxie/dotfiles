---
status: accepted
title: Claude Code settings merge, and the profile follows the work tree
---

Recorded from `42ac515` (2026-07-10) and `ac11676` (2026-09-04).

## Context

Two Claude Code accounts live on the laptop: personal in `~/.claude`,
work (qualia) in `~/.claude-qualia`, chosen by `CLAUDE_CONFIG_DIR`. Set by
hand, the variable was set wrong, and a work setup tool installed the work
skills and guard into the personal profile. Separately, `settings.json`
has three authors: what this config declares, what Claude Code writes at
runtime (`/voice`, `/theme`, onboarding), and what the work tooling
writes. A read-only store symlink broke the runtime writes; a copy
replaced on every switch silently dropped the other two authors' keys.

## Decision

- The directory decides the profile. fish's `_claude_profile` runs at
  shell start and on every `cd`: under `~/repos/work` it sets
  `CLAUDE_CONFIG_DIR=~/.claude-qualia`, anywhere else it erases the
  variable (unset is what Claude Code reads as `~/.claude`). The terminal
  background is tinted while the work profile is active.
- `settings.json` is seeded by a home-manager activation script that
  merges the declared settings over the existing file with `jq`, key by
  key, declared values winning; an unparseable file is reported and
  reseeded rather than failing the activation. `CLAUDE.md`, skills and
  themes stay store links.
- The work profile declares its plugin marketplace and plugin enablement;
  the plugin payload and the work guard's deny rules stay imperative,
  owned by the tools that maintain them.

## Consequences

- A setting changed in a session survives a switch unless this config
  declares the same key, in which case the switch resets it; declared
  values (voice tap mode, theme, permissions mode) are changed here.
- Opening a terminal in the wrong directory still selects the wrong
  account for anything started there; the rule is a convention of the
  directory layout.
