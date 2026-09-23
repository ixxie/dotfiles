---
title: Managing secrets
---

# Managing secrets

All secrets are in `secrets.yaml`, one sops file encrypted to the
operator's age key (`.sops.yaml` names it). Only the operator can decrypt
it; an agent never opens it, never reads `/run/secrets`, and never prints a
value. The design is recorded in
[sops-nix holds the secrets](corpus:decision/26-02-16-sops-nix-holds-the-secrets)
and [secretEnv exports secrets to shells](corpus:decision/26-03-29-secretenv-exports-secrets-to-shells).

## What is there

By name only:

| sops key | declared in | reaches |
|---|---|---|
| `nix-access-tokens` | `nix.nix` | nix daemon and user `nix.conf` (`!include`) |
| `openrouter-api-key` | `modules/agents/default.nix` | `$OPENROUTER_API_KEY` via secretEnv |
| `hetzner-api-key` | `modules/hetzner.nix` | `$HCLOUD_TOKEN` via secretEnv |
| `gandi-api-key` | `modules/gandi.nix` (staged) | `$GANDI_TOKEN` via secretEnv |
| `proton-bridge-password` | `modules/proton.nix` | mbsync `passwordCommand` |
| `restic-password` | `modules/restic-backup.nix` | `RESTIC_PASSWORD_FILE` in the backup job |
| `protonvpn-key` | `modules/torrent.nix` | the WireGuard private key, root only |

Three more keys are in the file and used by nothing:
`cella-credentials`, `opencode-api-key`, `paseo-password` (see
[orphan secrets](corpus:issue/26-09-23-orphan-secrets-and-a-dead-token-path)).

## Add a secret

1. **Put the value in the file** (the operator):

   ```sh
   sops secrets.yaml      # add a line:  my-service-key: <value>
   ```

   Do this first. sops-nix refuses to build a system that names a secret
   the file lacks, and sops re-encrypts the whole file, so every other
   entry rides along in the diff.

2. **Declare it in the module that uses it**, not in a central list:

   ```nix
   sops.secrets.my-service-key = {
     owner = "ixxie";
     mode = "0400";
   };
   ```

   At activation it is decrypted to `/run/secrets/my-service-key`
   (`config.sops.secrets.my-service-key.path`), owned as declared. Point
   whatever needs it at that path: a `passwordCommand`, a `*_FILE`
   variable, an `!include`.

3. **Or export it to shells**, when a CLI (and so an agent) reads it from
   the environment:

   ```nix
   secretEnv."my-service-key" = "MY_SERVICE_TOKEN";
   ```

   `lib/secret.nix` declares the sops secret (owner `ixxie`) for you and
   adds, per entry, a guarded read of the file into the variable: in fish's
   interactive init, and in `environment.extraInit`, which NixOS writes to
   `/etc/set-environment` for bash and sh. A missing file is skipped
   silently.

4. **Switch** (`yo gen switch`, see [applying changes](corpus:guide/applying)).

## A new value needs new processes

sops-nix writes the new value at switch time, but nothing already running
sees it:

- A **new fish shell** reads the file at startup and gets the new value.
- A **running shell, and everything started from it**, keeps the old one.
  That includes agent sessions (Claude Code, Codex, OpenCode), tmux or
  zellij servers, and any long-running helper an agent spawned. Restart
  them after rotating a token; an agent that reports an auth failure right
  after a rotation is usually holding the old value.
- **bash and sh** read `/etc/set-environment` once per session tree: it
  exports `__NIXOS_SET_ENVIRONMENT_DONE` and children skip it, so a new
  terminal tab under an old session inherits the old value. A fresh login
  gets the new one.
- **systemd services** get none of this. A daemon that needs a token
  reads the secret file itself (as the backup does with
  `RESTIC_PASSWORD_FILE`), and a daemon that caches it needs a restart.

## Rotate or remove

Rotate: `sops secrets.yaml`, change the value, switch, restart the
consumers above. Remove: drop the declaration or the `secretEnv` entry,
switch, then delete the key from the file with `sops`; the other order
fails the build.
