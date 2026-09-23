---
status: accepted
title: The theme is one base16 scheme, as plain data
---

Recorded from the Stylix removal (`4fd86ce`, 2026-02-28) and `826d4cc`
(2026-04-03, "inline base16 color scheme and app themes").

## Context

Stylix themed everything automatically from 2025-03, but decided for
itself which programs it touched and how, and fought hand-written
program configs. After it, per-app base16 flake inputs (tt-schemes and
friends) each pulled their own templates.

## Decision

`theme.nix` defines the palette once, as `config.scheme` from base16.nix:
a plain attrset of the sixteen base16 colors, set to Everforest Dark Hard.
Each program's theme is written in its own module and reads the scheme:
fish colors, helix and yazi themes, ghostty's palette, tuigreet and the
console, cyberdeck's background, the Voyager overlay, and the Claude Code
color overrides (`mkPalette`). Fonts are Monaspace Nerd Fonts throughout.

## Consequences

- Changing the scheme's sixteen values re-themes the whole system on the
  next switch; changing one program's look is an edit in its own module.
- Each program's template is maintained here, taken from the upstream
  tinted-theming templates and cited in a comment where it came from.
- No external theming input is needed; base16.nix only supplies the
  option.
