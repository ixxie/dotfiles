---
status: accepted
title: secretEnv exports secrets to shells
---

Recorded from `9f2b957` (2026-03-29, `lib/secret.nix` added).

## Context

Many CLIs take their credentials from an environment variable
(`HCLOUD_TOKEN`, `OPENROUTER_API_KEY`). sops-nix only writes files. Each
module wiring its own export into fish, and forgetting bash, would repeat
the same lines and miss shells.

## Decision

`lib/secret.nix` defines one option, `secretEnv`, a map from sops secret
name to variable name. For each entry it declares the sops secret (owner
`ixxie`) and adds a guarded read of the decrypted file into the variable,
in fish's interactive init and in `environment.extraInit` for POSIX
shells. A module wanting a token in the environment writes one line:

```nix
secretEnv."hetzner-api-key" = "HCLOUD_TOKEN";
```

## Consequences

- The value is in the environment of every interactive shell and every
  process started from one, agents included. That is intended (see
  [agents get tokens through secretEnv](corpus:decision/26-09-23-agents-get-tokens-through-secretenv))
  and also its exposure: anything in the session can read it.
- Values are read when a shell starts; a rotated value needs new shells
  and restarted agent sessions (see [managing secrets](corpus:guide/secrets)).
- systemd services do not get these variables and read secret files
  directly.
