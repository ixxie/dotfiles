---
status: open
title: Backup failures are silent
---

## Problem

The backup failed every night from amoeba's destruction until someone
looked, because a failed run of `restic-backup-bacillus.service` is only
recorded in the journal. Nothing tells the operator.

Also in `modules/restic-backup.nix`: a comment in `serviceConfig` says the
job does not run on battery via `ConditionACPower` and that the timer
gates it too; neither is set. The job runs on battery.

Options: an `OnFailure=` unit that sends a desktop notification
(`notify-send` through the user session) or pings a dead-man's-switch
URL; a cyberdeck badge reading the unit's state; and either adding
`ConditionACPower=true` or deleting the comment.

## Done when

A failed backup run is visible to the operator the same day without
reading the journal, and the comment matches the unit.
