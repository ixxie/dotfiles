---
title: Backup
---

# Backup

The home directory is backed up daily with restic to the personal server,
bacillus. Everything is in `modules/restic-backup.nix`; the reasoning is in
[backup to bacillus by its public name](corpus:decision/26-09-23-backup-to-bacillus-by-public-name).

## Where it goes

| | |
|---|---|
| repository | `sftp:ixxie@bacillus.corpus.pub:/var/backup/restic/contingent` |
| storage | a Hetzner Volume mounted at `/var/backup` on bacillus, which outlives the VM |
| transport | SFTP over ssh as `ixxie`, key-only, by public DNS; no tailnet |
| password | sops secret `restic-password`, passed as `RESTIC_PASSWORD_FILE` |
| source | `/home/ixxie`, `--one-file-system`, tagged `daily`, host `contingent` |
| schedule | `restic-backup-bacillus.timer`: 03:00, up to 30 min jitter, `Persistent` (a missed run happens at next boot) |
| retention | `forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune` after each run |

The service runs as `ixxie` at `Nice=19` with idle IO priority. It
initializes the repository if it cannot list snapshots (the first run
against a fresh volume) and clears stale locks before backing up.

## What is left out

The exclude file is written inline in the module. By group:

- **Caches and regenerable tool state:** `.cache`, Trash, browser caches
  and storage (Firefox, Chrome, Zen), Discord caches, Signal attachments,
  npm, cargo registry and git, rustup toolchains, Go packages, pnpm and bun
  caches. Directories tagged with `CACHEDIR.TAG` are skipped as well
  (`--exclude-caches`).
- **Scratch:** `temp` (the downloads directory).
- **Client work, never on the personal server:** `projects/office` and
  `repos/work`.
- **Build artifacts** anywhere under `repos/` and `projects/`: `target`,
  `result*`, `node_modules`, `.direnv`, and under `repos/` also `dist`
  and `build`.
- **Re-cloneable upstream code:** `repos/foss`, `projects/community`.
- **Parked checkouts:** `repos/lab/.archive`.
- **Nix noise:** `.nix-profile`, `.local/state/nix`.

Paths are relative to the home and cover both the current `~/repos` layout
and the planned `~/projects` one. To exclude something new, add a line to
the `excludes` text and switch.

## Run and check it

```sh
systemctl start restic-backup-bacillus     # run now instead of waiting for 03:00
systemctl status restic-backup-bacillus    # last result
journalctl -u restic-backup-bacillus -e    # its log
systemctl list-timers restic-backup-bacillus
```

A failed run is only visible there; nothing notifies (see
[backup failures are silent](corpus:issue/26-09-23-backup-failures-are-silent)).
The first run against bacillus still waits on a switch (see
[the first run](corpus:issue/26-09-23-backup-first-run-waits-on-a-switch)).

## Restore

As `ixxie`, with the repository and password in the environment:

```sh
export RESTIC_REPOSITORY=sftp:ixxie@bacillus.corpus.pub:/var/backup/restic/contingent
export RESTIC_PASSWORD_FILE=/run/secrets/restic-password

restic snapshots                                     # what exists
restic ls latest /home/ixxie/docs                    # browse one
restic restore latest --target /tmp/restore \
  --include /home/ixxie/docs/some-file               # restore a path
restic restore <snapshot-id> --target /tmp/restore   # restore a whole snapshot
restic mount /tmp/restic                             # browse every snapshot as files
```

Restore into a scratch target and copy back; restoring over the live home
overwrites without asking. On a machine without this config, the password
has to come from `secrets.yaml` through `sops -d`, which needs the
operator's age key: keep a copy of that key somewhere that is not this
laptop, or the backup cannot be read after losing it.
