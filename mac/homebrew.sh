#!/usr/bin/env bash

set -e

if ! [[ -x "$(command -v brew)" ]]; then
    /usr/bin/ruby -e "$(curl -fsSL \
            https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

brew doctor

brew bundle
