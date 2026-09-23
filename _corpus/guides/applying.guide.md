---
title: Applying changes
---

# Applying changes

Changes to this repository do nothing until the operator switches to them.
Agents may edit and evaluate; only the operator applies (see
[`yo gen` is the only apply path](corpus:decision/26-03-14-yo-gen-is-the-only-apply-path)).

## Check before switching (anyone, read-only)

Nix flakes only see files git knows about, so add a new file to the index
first, at least as an intent:

```sh
git add -N modules/new-thing.nix
```

Then evaluate. This builds nothing and changes nothing on the system:

```sh
nix eval .#nixosConfigurations.contingent.config.system.stateVersion
nix eval .#nixosConfigurations.contingent.config.services.greetd.settings.default_session.command
```

The first proves the whole module set still evaluates; the second style
reads back one option to confirm a change took the shape you meant. A
build without switching, if you want the closure checked too:

```sh
nix build .#nixosConfigurations.contingent.config.system.build.toplevel --dry-run
```

A secret named in the config but missing from `secrets.yaml` does not fail
evaluation; sops-nix refuses it when the system is built, so add the value
before switching (see [managing secrets](corpus:guide/secrets)).

## Switch (the operator)

```sh
yo gen switch        # stage everything, update local inputs, rebuild, switch
yo gen switch -u     # the same after `nix flake update` of every input
yo gen commit        # commit first (Claude plans the commits), then switch with a label
```

What `yo gen switch` does, in order:

1. with `-u`, `sudo nix flake update`;
2. updates local `path:` inputs by name (see
   [yo misses git+file local inputs](corpus:issue/26-09-23-yo-misses-git-file-local-inputs):
   cyberdeck and janeway are `git+file:` and are not caught);
3. `git add -A` in the repository, which stages every change, including
   ones you meant to keep out of the index (see
   [yo gen switch stages the whole tree](corpus:issue/26-09-23-yo-gen-switch-stages-the-whole-tree));
4. `sudo env <.env lines> NIXOS_LABEL=<label> nixos-rebuild switch --impure --flake ~/repos/lab/dotfiles#contingent`.

`--impure` is needed because `system.nix` reads `NIXOS_LABEL` from the
environment. `yo gen commit` builds the label from the new HEAD's short hash
and subject; `yo gen switch` leaves the generation "unlabeled".

A switch that changes the niri package, a sops secret or a user service may
need more than the switch: log out and in for niri, open a new shell for a
changed `secretEnv` value, restart the cyberdeck bar after a cyberdeck
update.

## Roll back

```sh
yo gen list          # generations, newest first, * marks the current one
yo gen back          # nixos-rebuild switch --rollback
yo gen pick          # search the generations and switch to one
```

`yo gen pick` runs the chosen generation's own `switch-to-configuration`.
If the desktop does not come up at all, pick an older generation from the
systemd-boot menu; ten are kept there.

## Clean up

```sh
yo gen gc
```

It removes unlabeled generations, labeled ones beyond the ten newest once
they are two weeks old, and any labeled generation older than sixty days
(the current one is always kept), then runs `nix-collect-garbage` and
`nix-store --optimise` and reports how full `/boot` is. The ESP only
releases the removed kernels at the next switch, which reinstalls the
bootloader.

Garbage collection is also where a remembered store path breaks; see
[the greeter decision](corpus:decision/26-08-14-greeter-sessions-come-from-the-closure).
