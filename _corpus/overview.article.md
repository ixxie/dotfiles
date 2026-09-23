---
title: Overview
---

# Overview

This repository is **config**: the whole declared state of one laptop and
the person who uses it. It is a Nix flake with a single output,
`nixosConfigurations.contingent`, which builds the NixOS system of
**contingent** (a Framework 13, AMD Ryzen 7040 series), and inside that
system the home directory of its one user, `ixxie`, through home-manager. It
also carries `yo`, a small Bun/TypeScript CLI that applies the config and
does a few personal chores besides.

It is a home project in both senses. It configures a home, and it lives the
way home projects do: bursts of work when something breaks or itches, long
quiet stretches in between, and a history that reaches back to 2016 (see
[history](corpus:article/history)).

## What it holds

- **The host.** Boot, kernel, disks, firmware, networking, nix settings,
  the greeter, printing, docker, the Framework and ZSA keyboard support.
- **The user.** Shell (fish, starship, eza, zoxide), editor (helix),
  terminal (ghostty), file manager (yazi), the niri compositor and the
  cyberdeck bar, browsers, messaging, mail, media, design tools, and the
  coding agents (Claude Code, Codex, OpenCode) with their shared
  instructions and skills.
- **Services.** sops-nix for secrets, tailscale, a restic backup to the
  personal server, a VPN-namespaced transmission daemon, the Proton Mail
  bridge.
- **The `yo` CLI** under `cli/`.

The two halves are not separated. Most modules under `modules/` set NixOS
options and `home-manager.users.ixxie` options side by side, one file per
concern, so "the host" and "the user" are a reading of the code rather than
a directory. [Architecture](corpus:article/architecture) maps it, and
[splitting the host and user config](corpus:issue/26-09-23-split-host-and-user-config)
is the open plan to change it.

## How it is applied

The config is applied by the **operator**, on the laptop, with
`yo gen switch` (or `yo gen commit`, which first commits the working tree
with an AI-written commit plan). Both end in
`sudo nixos-rebuild switch --impure --flake ~/repos/lab/dotfiles#contingent`,
with a generation label in `NIXOS_LABEL`. `yo gen back` and `yo gen pick`
roll back; `yo gen gc` prunes generations. See
[applying changes](corpus:guide/applying) and the decision that
[`yo gen` is the only apply path](corpus:decision/26-03-14-yo-gen-is-the-only-apply-path).

Agents edit this repository but never apply it. An agent session on the
laptop does not run `yo`, `nixos-rebuild` or `switch-to-configuration`; it
may evaluate the flake, which is read-only, and it hands the switch to the
operator.

## The secret model

Secrets live in one sops file, `secrets.yaml`, encrypted to the operator's
age key. sops-nix decrypts them at activation into `/run/secrets/<name>`,
each declared by the module that consumes it. Tokens that a shell (and so
an agent) needs are exported by `lib/secret.nix`: a module writes
`secretEnv."<sops name>" = "<ENV_VAR>";` and every new shell reads the file
into the variable.

```
secrets.yaml  --(sops-nix, at switch)-->  /run/secrets/<name>
              --(secretEnv, at shell start)-->  $ENV_VAR in fish, bash, sh
```

See [managing secrets](corpus:guide/secrets) and the decisions on
[sops-nix](corpus:decision/26-02-16-sops-nix-holds-the-secrets),
[secretEnv](corpus:decision/26-03-29-secretenv-exports-secrets-to-shells) and
[tokens for agents](corpus:decision/26-09-23-agents-get-tokens-through-secretenv).

## The role of `yo`

`yo` is the operator's hand on the system. Its `gen` command is the apply
path: switch, commit-and-switch, list, back, pick, gc, and a TUI dashboard
over generations and builds. The rest is personal tooling: `yo cd` and
`yo repos` over `~/repos`, `yo open` for desktop apps, `yo tree`,
`yo media` (a watchlist, ratings and torrent browser over a local SQLite
database, reaching the torrent search through the VPN namespace's proxy),
`yo noir` (Celluloid in black and white) and `yo discord purge`.

The `yo` on the PATH is a wrapper declared in `modules/fish.nix` that runs
`cli/src/index.ts` with Bun straight from the working tree, so an edit to
the CLI is live without a rebuild. `cli/default.nix` still describes a
packaged build, but nothing uses it.
