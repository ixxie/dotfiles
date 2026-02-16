
## [ixxie](https://shenhav.fyi)'s dotfiles

This repo stores my dotfiles, organized as a [NixOS](https://nixos.org) config in a Nix flake, with
[Home-Manager](https://github.com/nix-community/home-manager) installed [as a NixOS module](https://nix-community.github.io/home-manager/index.xhtml#sec-install-nixos-module).

### philosophy

- **declarative** - configure as much as possible in these files
- **lazy** - avoid things that require too much config and effort
- **neat** - keep it visually and programmatically tidy

### desktop

- [**Niri**](https://github.com/YaLTeR/niri) - scrolling tiling compositor
- [**Noctalia**](https://github.com/noctalia-dev/noctalia-shell) - wayland shell w/ bar, launcher & notifications
- [**Stylix**](https://nix-community.github.io/stylix/) - system-wide theming

I also keep a [Gnome](https://www.gnome.org/) desktop as a backup.

### shell

- [**Helix**](https://helix-editor.com/) - modal text editor
- [**Ghostty**](https://ghostty.org/) - terminal emulator
- [**Nushell**](https://www.nushell.sh/) - data-orientated shell

### cells

Ephemeral [microVMs](https://github.com/astro/microvm.nix) for running Claude Code with `--dangerously-skip-permissions` in isolated sandboxes. Each cell is tied to a **repo + branch** pair - work on features in isolation, sync changes via git.

```fish
# create & enter (from any repo)
org cell create feat-auth  # create branch + cell + git remote
org cell shell             # SSH into cell (auto-creates if needed)

# sync changes
org cell pull              # fetch from cell → main repo
org cell push              # push from main repo → cell

# manage
org cell up / down         # start/stop VM
org cell list              # cells for current repo (-a for all)
org cell slots             # show VM slot status
org cell destroy           # remove cell (-b to also delete branch)
```

4 VM slots (4GB RAM, 4 vCPU each). Data persists in `~/.local/share/cell/<repo>/<branch>/`.
