---
status: accepted
title: One agents module for every coding agent
---

Recorded from `50a4c51` (2026-05-21), which created `modules/agents/`,
and `9d7a384` (2026-09-18, Codex added to it).

## Context

Claude Code had its own module since 2025-09, OpenCode another, and each
carried its own copy of the operator's instructions and skills, which
drifted.

## Decision

`modules/agents/` configures every coding agent from one source:

- `AGENTS.md` is the single instruction file: Claude Code gets it as
  `CLAUDE.md` in each profile, Codex as its context, OpenCode as
  `~/.config/opencode/AGENTS.md`.
- `skills/*.md` is the single skills directory, installed into each
  Claude profile and into Codex.
- Claude Code (from sadjow/claude-code-nix), Codex (sadjow/codex-cli-nix)
  and OpenCode (dan-online/opencode-nix) come from flakes, pinned in the
  lock, with self-update turned off where the tool has the setting.
- Provider keys the agents need are exported with `secretEnv`
  (`OPENROUTER_API_KEY` here).

## Consequences

- An instruction or a skill is edited once and every agent gets it at
  the next switch.
- Agent versions move with `flake.lock`, not with the agents' own
  updaters.
- Settings files the agents write at runtime cannot be store symlinks;
  Claude's are merged on activation
  ([Claude settings](corpus:decision/26-09-04-claude-settings-merge-and-follow-the-work-tree))
  and Codex's defaults live in `/etc/codex/config.toml`.
