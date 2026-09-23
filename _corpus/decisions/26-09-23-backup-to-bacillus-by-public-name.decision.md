---
status: accepted
title: The home is backed up to bacillus, by its public name
---

Recorded from `01f603c` (2026-06-02, the stop-gap to amoeba) and
`d58e8f9`, `55a338c`, `7e589ee` (2026-09-23).

## Context

The laptop had no backup until June 2026, when a restic job was added as
a stop-gap targeting amoeba, the Hetzner dev host of the time. amoeba was
destroyed in September 2026 and the job kept failing every night without
anyone noticing. Its replacement, bacillus, keeps its backup on a Hetzner
Volume that outlives the VM. The first retarget reached bacillus over
tailscale, but the tailnet on this laptop is not to be used for this
work.

## Decision

- restic, daily, over SFTP as `ixxie`, to
  `bacillus.corpus.pub:/var/backup/restic/contingent`, reached by public
  DNS with key-only ssh; no tailnet is involved.
- The whole home is included except scratch (`temp`), regenerable caches
  and build artifacts, re-cloneable upstream code, and **client work**
  (`projects/office`, `repos/work`), which never lands on the personal
  server.
- The job initializes the repository on first run, clears stale locks,
  and keeps 7 daily, 4 weekly and 6 monthly snapshots.

## Consequences

- The personal server holds a copy of everything personal on the
  laptop, readable with the restic password, which lives in sops and so
  depends on the operator's age key.
- Failures are only in the journal
  ([backup failures are silent](corpus:ticket/26-09-23-backup-failures-are-silent)).
- See [backup](corpus:guide/backup).
