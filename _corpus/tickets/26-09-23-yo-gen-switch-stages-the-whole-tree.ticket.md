---
status: todo
title: yo gen switch stages the whole tree
---

## Problem

Before rebuilding, `yo gen switch` runs `git add -A` in the repository,
and `yo gen commit` resets the index and re-stages per commit before
adding everything that is left. Both treat the index as theirs. That is
convenient (a new module is visible to the flake without remembering
`git add`) but it:

- stages files the operator deliberately kept out of the index, or a
  half-finished edit an agent left in the tree;
- mixes unrelated work into the "chore: remaining changes" commit that
  `yo gen commit` makes of leftovers;
- builds whatever is in the working tree, committed or not, so a
  generation's label does not say which tree it was built from.

It also passes every line of the gitignored `.env` to the rebuild as
environment, which is invisible from the repository.

Options: `git add --intent-to-add` for untracked files only (enough for
the flake to see them), and refusing to switch from a tree with changes
an agent made without the operator noticing.

## Done when

`yo gen switch` makes new files visible to the flake without rewriting
the operator's index.
