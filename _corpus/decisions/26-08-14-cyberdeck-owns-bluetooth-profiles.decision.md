---
status: accepted
title: cyberdeck owns bluetooth audio profiles
---

Recorded from `0e5c8a0` (2026-08-14), following the cyberdeck audio
rework of July 2026.

## Context

Bluetooth earbuds went through connect/disconnect loops. The radio was
fine; wireplumber's on-demand headset autoswitch raced HFP setup (the
RFCOMM link reset mid-open) and fought explicit switches. The legacy HSP
role kept failing SDP lookups and racing HFP, and the LE Audio (BAP) role
only produced errors, since bluetoothd has no ISO sockets enabled.

## Decision

Profile choreography belongs to cyberdeck's native pipewire backend,
which switches explicitly and verifies each stage (a2dp for listening,
HFP when something actually captures from the mic, back to a2dp when it
stops). `modules/media.nix` sets wireplumber's
`bluetooth.autoswitch-to-headset-profile = false` and trims `bluez5.roles`
to `a2dp_sink`, `a2dp_source` and `hfp_ag`. cyberdeck's airplane (rfkill)
module is enabled alongside.

## Consequences

- Without the cyberdeck bar running, nothing switches a headset to its
  mic profile.
- The config and cyberdeck must be deployed together when either side of
  this changes.
- Idle bluetooth disconnects, if they return, point at USB autosuspend,
  which is not declared here
  ([btusb autosuspend](corpus:issue/26-09-23-btusb-autosuspend-not-declared)).
