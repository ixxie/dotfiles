#!/usr/bin/env bash

dot_root=$(pwd -P)

set -e

##################################################
# Helper function to write out in color
# Arguments:
#   $1: String that is written out
#   $2: tput foreground color
#   $3: Flag -b for bold text
##################################################
function echo_c {
    if [[ $3 == "-b" ]]; then
        echo "$(tput bold && tput setaf $2)$1$(tput sgr0)"
    else
        echo "$(tput setaf $2)$1$(tput sgr0)"
    fi
}

##################################################
# Function for linking files and directories.
# Makes sure that there are no conflicts.
# Arguments:
#   None
##################################################
function link_file {
    local src="$dot_root/$1"
    local dst="$HOME/$2"

    # Check for directory.
    if [ ! -e "${dst%/*}" ]; then
        read -r -p "$(echo_c "No directory at target. Create a directory for '$dst' [y/n]? " 3)" prompt
        if [[ ! $prompt =~ ^[Yy]$ ]]; then
            return
        fi

        mkdir -p "${dst%/*}"
    fi

    # Unlink if link already exists.
    if [ -L "$dst" ]; then
        unlink "$dst"
    fi

    # Check if overwriting directory or file.
    if [ -d "$dst" ]; then
        read -r -p "$(echo_c "Directory '$dst' already exists. Do you wish to overwrite it [y/n]? " 3)" prompt
        if [[ ! $prompt =~ ^[Yy]$ ]]; then
            return
        fi

        rm -rf "$dst"
    elif [ -e "$dst" ]; then
        read -r -p "$(echo_c "File '$dst' already exists. Do you wish to overwrite it [y/n]? " 3)" prompt
        if [[ ! $prompt =~ ^[Yy]$ ]]; then
            return
        fi

        rm "$dst"
    fi

    echo "$(echo_c "Symlinking" 6) $dst"
    ln -s "$src" "$dst"
}

# Taken from https://github.com/holman/dotfiles/blob/master/script/bootstrap
##################################################
# Sets up git name and email to '.gitconfig.local'
# Arguments:
#   None
##################################################
function setup_gitconfig {
  if [ ! -f git/.gitconfig.local ]; then
    git_credential='cache'

    if [ "$(uname -s)" == "Darwin" ]; then
      git_credential='osxkeychain'
    fi

    read -r -p "$(echo_c "What is your git user.name? " 3)" git_authorname
    read -r -p "$(echo_c "What is your git user.email? " 3)" git_authoremail

    sed -e "s/AUTHORNAME/$git_authorname/g" -e "s/AUTHOREMAIL/$git_authoremail/g" -e "s/GIT_CREDENTIAL_HELPER/$git_credential/g" git/.gitconfig.local.example > git/.gitconfig.local
  fi
}

##################################################
# Links the common files and directories.
# Arguments:
#   None
##################################################
function linker {
    link_file "sh/.bash_profile" ".bash_profile"
    link_file "sh/.bashrc" ".bashrc"
    link_file "sh/base16-shell" ".config/base16-shell"
    link_file "sh/.zshrc" ".zshrc"
    link_file "sh/zsh/" ".zsh"
    link_file "git/.gitconfig" ".gitconfig"
    link_file "git/.gitignore" ".gitignore"
    link_file "git/.gitconfig.local" ".gitconfig.local"
    link_file "vim/.vimrc" ".vimrc"
    link_file "vim/pack/" ".vim/pack"
    link_file "vim/colors/base16-eighties.vim" ".vim/colors/base16-eighties.vim"
}

echo_c "Setting up .gitconfig" 2 -b
setup_gitconfig

echo_c "Linking common files." 2 -b
linker

echo_c "Initializing submodules." 2 -b
git submodule update --init --recursive

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo_c "Running MacOS-specific stuff." 2 -b

    link_file "tmux/.tmux-osx.conf" ".tmux.conf"

    read -r -p "$(echo_c "Run defaults.sh? " 3)" prompt
    if [[ $prompt =~ ^[Yy]$ ]]; then
        sh ./osx/defaults.sh
    fi

    read -r -p "$(echo_c "Run homebrew.sh? " 3)" prompt
    if [[ $prompt =~ ^[Yy]$ ]]; then
        sh ./osx/homebrew.sh
    fi
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    echo_c "Running Linux-specific stuff." 2 -b

    link_file "tmux/.tmux-linux.conf" ".tmux.conf"
    link_file "linux/xfce-term/" ".config/xfce4/terminal"
    link_file "linux/openbox/" ".config/openbox"
    link_file "linux/x/.xinitrc" ".xinitrc"
    link_file "linux/x/.Xresources" ".Xresources"
    link_file "linux/x/.xbindkeysrc" ".xbindkeysrc"
    link_file "linux/napapiiri/" ".themes/napapiiri"
    link_file "linux/i3/" ".config/i3"
    link_file "linux/polybar/" ".config/polybar"
    link_file "linux/compton/compton.conf" ".config/compton.conf"

    if [[ -f /etc/arch-release ]]; then
        read -r -p "$(echo_c "Run pacman.sh? " 3)" prompt
        if [[ $prompt =~ ^[Yy]$ ]]; then
            sh ./linux/scripts/pacman.sh
        fi
    fi

    read -r -p "$(echo_c "Run lein_install.sh? " 3)" prompt
    if [[ $prompt =~ ^[Yy]$ ]]; then
        sh ./linux/scripts/lein_install.sh
    fi
fi

echo_c "Done." 2 -b
