#!/usr/bin/env bash

# Identify dotfiles path by finding this script's directory
dotfiles="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Ensure a directory exists
function direx
{
    if [ ! -d $1 ]; then
        parent = dirname $1
        if [ ! -d parent ]; then
            direx parent
        else
            mkdir $1
        fi
    fi
}

# Make a symbolic link, ensuring the directory exists
function linkex
{
    direx dirname $2
    ln -s $1 $2
}

# Initialize & update submodules of dotfiles:
git submodule init
git submodule update

# Link the home-manager:
linkex ${dotfiles}/nix/home-manager ~/.config/nixpkgs/home-manager
linkex ${dotfiles}/nix/home-manager/overlay.nix ~/.config/nixpkgs/overlays/home-manager.nix
linkex ${dotfiles}/nix/home.nix ~/.config/nixpkgs/home.nix
linkex ${dotfiles}/nix/config.nix ~/.config/nixpkgs/config.nix

nix-env -f '<nixpkgs>' -iA home-manager

home-manager switch
