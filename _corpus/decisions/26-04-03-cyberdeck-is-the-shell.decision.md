---
status: accepted
title: cyberdeck is the desktop shell
---

Recorded from `4c7bd02` (2026-03-22, cyberdeck added) and `9b94ec3`
(2026-04-03, "remove noctalia shell integration").

## Context

On niri the bar, launcher, notifications and system controls came from
third-party shells: waybar, then eww, then Noctalia (from 2025-09-13).
Each needed its own theming and its own workarounds (Noctalia was launched
from niri, then from systemd, then from niri again within a day in March
2026).

## Decision

The shell is cyberdeck, the operator's own Wayland shell, developed in a
sibling repository (`lab/cyberdeck`) and consumed as a flake input by
`git+file:`. `modules/cyberdeck.nix` enables it and its modules (calendar,
workspaces, network, session, audio, bluetooth, airplane, system,
brightness, notifications, weather, recording, screenshot, storage,
window, wallpaper), takes its background from the base16 scheme, and niri
binds the launcher, screenshots, volume, brightness and media keys to
`cyberdeck` commands.

## Consequences

- The desktop and its shell evolve together; a cyberdeck change reaches
  the laptop only after it is committed in its repository, the input is
  updated, the system switched and the bar restarted.
- cyberdeck took over responsibilities that used to be configured here,
  such as bluetooth profile switching
  ([cyberdeck owns bluetooth profiles](corpus:decision/26-08-14-cyberdeck-owns-bluetooth-profiles)).
- cyberdeck is a personal prototype for a future desktop distribution, in
  maintenance mode, so this config depends on it staying usable.
