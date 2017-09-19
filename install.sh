#!/usr/bin/env bash

dotfiles = dirname $0

ln -s ${dotfiles}/nix/home.nix ~/.config/nixpkgs/home.nix
ln -s ${dotfiles}/nix/config.nix ~/.config/nixpkgs/config.nix
ln -s ${dotfiles}/nix/home-manager ~/.config/nixpkgs/home-manager

