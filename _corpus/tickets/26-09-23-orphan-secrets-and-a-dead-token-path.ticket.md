---
status: todo
title: Orphan secrets, and a dead token path in fish
assignee: ixxie
---

## Problem

`secrets.yaml` holds three keys that no module declares:
`cella-credentials`, `opencode-api-key` and `paseo-password`. They date
from the cella module, the OpenCode provider setup and the paseo service,
all since removed. They are encrypted, so they leak nothing, but a
secret nobody uses is a secret nobody rotates.

`modules/fish.nix` still reads `$DOTFILES/secrets/github_token.txt` into
`CR_PAT` at shell start. That file predates sops; the `secrets/`
directory no longer exists, so the read does nothing, and the GitHub
token the nix daemon uses comes from the `nix-access-tokens` sops secret
instead.

## Done when

The three keys are revoked upstream where they are real credentials and
removed from `secrets.yaml` with `sops`, and the `CR_PAT` block is
removed from `fish.nix` (or moved to `secretEnv` if something still
needs it).
