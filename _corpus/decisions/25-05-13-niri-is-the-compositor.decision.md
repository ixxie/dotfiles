---
status: accepted
title: niri is the compositor
---

Recorded from `f419164` ("niri tweaks", 2025-05-13) and the niri commits
that followed.

## Context

The desktop had been GNOME for years, with xmonad, Openbox and Plasma
tried along the way. A scrolling tiling Wayland compositor fits a laptop
screen with an external monitor better than a fixed grid.

## Decision

The desktop is niri, from niri-flake's `niri-unstable`, configured
declaratively through niri-flake's home-manager module in
`modules/niri.nix`. The greeter launches `niri-session`. xwayland-satellite
provides X11. Portals: gtk by default, gnome for screencast (niri speaks
Mutter's ScreenCast API; the wlr portal froze Discord shares on their
first frame), wlr for screenshots, termfilechooser (yazi) for file
choosing.

## Consequences

- niri is built locally rather than from the niri cache on purpose: the
  cached package pulls a ~1.3G closure that shares nothing with the system
  and risks a mesa mismatch. When nixpkgs moves under niri-flake, the
  config carries a compatibility overlay (`libdisplay-info_0_2` since
  2026-08-14) until upstream catches up.
- A nixpkgs bump that rebuilds niri moves its session file; that is what
  exposed the greeter bug
  ([greeter sessions come from the closure](corpus:decision/26-08-14-greeter-sessions-come-from-the-closure)).
- The bar, launcher and system controls are not niri's job; see
  [cyberdeck is the shell](corpus:decision/26-04-03-cyberdeck-is-the-shell).
