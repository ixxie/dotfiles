---
status: open
title: Bluetooth USB autosuspend is not declared
---

## Problem

During the bluetooth audio work of July 2026, disabling USB autosuspend
for the bluetooth adapter (`btusb.enable_autosuspend=0`) was tried as a
runtime toggle, and it is lost on reboot. It was left out of the config
because the loops it targeted turned out to be wireplumber's profile
autoswitch ([cyberdeck owns bluetooth profiles](corpus:decision/26-08-14-cyberdeck-owns-bluetooth-profiles)).

## Done when

Either idle-time bluetooth disconnects recur and
`boot.extraModprobeConfig = "options btusb enable_autosuspend=0"` (or the
kernel parameter) goes into `device.nix`, or a few weeks pass without
them and this is closed as not needed.
