---
status: todo
title: The media command's API keys are committed in source
assignee: ixxie
---

## Problem

`cli/src/lib/tmdb.ts` and `cli/src/lib/omdb.ts` each hold a third-party
API key as a string constant, committed in plain text and published with
the repository to Codeberg and its GitHub mirror. They are low-value
keys for public metadata APIs, but they are the only credentials in this
repository outside sops.

## Done when

Both keys are rotated, the new values are sops secrets exported with
`secretEnv` (for example `TMDB_API_KEY`, `OMDB_API_KEY`), and `yo media`
reads them from the environment.
