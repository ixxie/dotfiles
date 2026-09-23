---
status: todo
title: The greeter's remembered session is still a cached path
---

## Problem

The "no command defined" failure is fixed
([greeter sessions come from the closure](corpus:decision/26-08-14-greeter-sessions-come-from-the-closure)),
but the ingredients are still there: tuigreet runs with
`--remember-session`, which keeps writing the chosen session's path to
its cache under `/var/cache/tuigreet`. After a rebuild that moves niri and
a GC, that cached path dangles again. The fix makes the session list
come from the closure and adds `--cmd niri-session` as the fallback, so
login should recover, but the path has not yet been through that cycle.

Notes on the failure shape, for the next time the greeter misbehaves:

- It presents as plausible state (an empty list, "no command defined"),
  not as an error, and only after a GC, often days after the rebuild that
  caused it.
- An older, un-collected generation from the boot menu still logs in;
  that is the recovery.
- A full ESP fails the switch that would repair things; systemd-boot is
  capped at 10 generations for that reason.

## Done when

A rebuild that changes niri's store path, followed by `yo gen gc`, has
logged in normally, or `--remember-session` has been dropped.
