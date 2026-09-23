---
status: accepted
title: sops-nix holds the secrets
---

Recorded from `fd0c218` (2026-02-16, sops-nix added) and `fc6dde5`
(2026-02-28, "distribute sops secrets to consuming modules").

## Context

Before sops, tokens lived in gitignored files under `secrets/` read by
shell init (one such read, of a GitHub token, is still in `fish.nix`), or
were pasted by hand. Nothing about them was declared, and a fresh machine
had no record of what it needed.

## Decision

Secrets are encrypted in the repository, in a single `secrets.yaml`,
with sops and one age key (the operator's, at
`~/.config/sops/age/keys.txt`, named in `.sops.yaml`). sops-nix decrypts
them at activation into `/run/secrets`. Each secret is declared by the
module that consumes it, with its owner and mode there, rather than in a
central secrets module.

## Consequences

- The repository says which secrets exist and who reads each one; the
  values stay unreadable without the key.
- A config that names a secret the file lacks fails to build, so a value
  is added with `sops secrets.yaml` before the module that needs it is
  switched in.
- sops re-encrypts the whole file on every edit, so every change to
  `secrets.yaml` touches every entry in the diff.
- Losing the age key loses every secret and the backup's password with
  them.
- See [managing secrets](corpus:guide/secrets).
