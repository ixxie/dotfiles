---
status: open
title: yo gen misses git+file local inputs
---

## Problem

`yo gen switch` and `yo gen commit` "always update local inputs", so that
a sibling repository's latest commit reaches the system. The detection in
`cli/src/commands/gen.ts` (`localInputNames`) matches inputs whose URL
starts with `path:`. Since 2026-05-21 the local inputs, cyberdeck and
janeway, are `git+file:` URLs, so the regex finds nothing and neither is
updated. A cyberdeck change reaches the laptop only after a manual
`nix flake update cyberdeck` or a full `yo gen switch -u`.

## Done when

`localInputNames` recognises `git+file:` (and `path:`) inputs, and a
cyberdeck commit is picked up by a plain `yo gen switch`.
