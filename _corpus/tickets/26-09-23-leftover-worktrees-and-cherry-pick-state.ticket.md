---
status: todo
title: Leftover worktrees and cherry-pick state
assignee: ixxie
---

## Problem

The repository carries debris from agent sessions:

- Three worktrees under `.claude/worktrees/` with branches
  `worktree-fix-eza-icons` (merged), `worktree-vercel-cli` (one commit
  not on main, whose change landed on main separately) and
  `worktree-gimp-plugins-fix` (two commits not on main, including "launch
  gimp via unversioned binary").
- A stale sequencer in `.git/sequencer` from an interrupted cherry-pick
  of those gimp commits, so `git status` reports a cherry-pick in
  progress although there is no `CHERRY_PICK_HEAD`.
- A `something` branch at an old WIP commit, fully merged.
- `main` is 16 commits ahead of `origin/main` (Codeberg), unpushed.

## Done when

The gimp commit is either on main or dropped, the worktrees and merged
branches are removed, the sequencer state is cleared
(`git cherry-pick --quit`), and main is pushed.
