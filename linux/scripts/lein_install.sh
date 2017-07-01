#!/usr/bin/env bash

set -e

dst="$HOME/.local/bin"

if [[ ! -e $dst ]]; then
    read -r -p "$(tput setaf 3)No directory at '$dst'. Create one [y/n]? $(tput sgr0)" prompt
    if [[ ! $prompt =~ ^[Yy]$ ]]; then
        exit 0;
    fi

    mkdir -p $dst
fi

curl -s \
    https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein \
    -o $dst/lein && chmod a+x $dst/lein

sh $dst/lein
