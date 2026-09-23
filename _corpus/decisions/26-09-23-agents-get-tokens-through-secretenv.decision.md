---
status: accepted
title: Agents get service tokens through secretEnv
---

Recorded from `f7ea779` (2026-09-23, "export the Hetzner token as
HCLOUD_TOKEN") and the staged `modules/gandi.nix`.

## Context

Provisioning the dev VM (bacillus) and managing DNS are agent work, and
each time an agent needed a token the operator pasted it into the
session. The Hetzner token had been in `secrets.yaml` for months without
reaching any shell.

## Decision

A service an agent is expected to drive gets its token as an environment
variable through `secretEnv`, in a small module that also installs the
CLI: `modules/hetzner.nix` (`HCLOUD_TOKEN`, with hcloud and
nixos-anywhere), `modules/gandi.nix` (`GANDI_TOKEN`, with jq for the v5
REST API, since nixpkgs dropped gandi-cli), and the agents module
(`OPENROUTER_API_KEY`). The operator adds the value with `sops` before
the switch that names it.

## Consequences

- An agent can provision and manage DNS without being handed a token in
  chat, and the token never appears in a transcript.
- Every process in the operator's session can read these tokens,
  including any agent and anything it runs. The tokens should be scoped
  as narrowly as the providers allow.
- After rotating one, running agent sessions keep the old value until
  restarted (see [managing secrets](corpus:guide/secrets)).
