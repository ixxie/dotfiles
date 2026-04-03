---
name: nix
description: Use when executing bash or shell commands or running CLI tools. Provides guidance for working in a NixOS environment.
user-invocable: false
---

# NixOS Environment

This is a NixOS system. Unlike traditional Linux distributions, many common commands may not be available.

**NEVER** attempt to install packages. No `apt`, `yum`, `pacman`, `npm install -g`, `pip install`, or similar — they don't exist or won't work here.

Instead, use `nix shell` to temporarily access any tool you need:

```
nix shell nixpkgs#jq -c 'jq .version package.json'
```

Multiple tools at once:

```
nix shell nixpkgs#curl nixpkgs#jq -c 'curl -s https://api.example.com | jq .'
```

To find the right package name: `nix search --json nixpkgs <query>`
