---
status: todo
title: The backup's first run to bacillus waits on a switch
assignee: ixxie
---

## Problem

The backup was retargeted to bacillus on 2026-09-23 (`d58e8f9`,
`55a338c`, `7e589ee`), but the running system still has the old unit,
which targets amoeba and fails every night. Nothing has been backed up
since amoeba was destroyed. The new unit only exists after the operator
runs `yo gen switch`.

After the switch, the first run can be started by hand rather than
waiting for 03:00:

```sh
systemctl start restic-backup-bacillus
journalctl -u restic-backup-bacillus -e
```

It should initialize the repository on the volume, then take the first
snapshot, which is large and slow over SFTP. The operator's ssh key must
be accepted by `ixxie@bacillus.corpus.pub`, and the host key must be
known to `ixxie`'s `known_hosts`, since the job runs non-interactively.

## Done when

`restic snapshots` against the repository lists a snapshot from
contingent (see [backup](corpus:guide/backup)).
