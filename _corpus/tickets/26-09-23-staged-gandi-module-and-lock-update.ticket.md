---
status: todo
title: The staged Gandi module and lock update await the operator
assignee: ixxie
---

## Problem

The index holds a change the operator staged and has not committed:

- `modules/gandi.nix` (new): exports the `gandi-api-key` sops secret as
  `GANDI_TOKEN` and installs jq, per
  [agents get tokens through secretEnv](corpus:decision/26-09-23-agents-get-tokens-through-secretenv);
- `flake.nix`: adds the module to the ops group;
- `secrets.yaml`: adds `gandi-api-key` (sops re-encrypted the file);
- `flake.lock`: an input update bumping eight locked inputs.

Because the flake reads the working tree, the staged module is already
part of what `nix eval` and the next `yo gen switch` see. The corpus
commits of 2026-09-23 were made with explicit paths and left all four
files staged and untouched, so the documentation of the Gandi module
(architecture, secrets guide) describes it ahead of its commit.

## Done when

The operator commits (or drops) the four files and switches.
