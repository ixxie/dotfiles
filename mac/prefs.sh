#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "$0")" && pwd -P)"

set -e

for i in $SCRIPT_ROOT/plists/*; do
    filename="$(basename $i)"
    dst_file="$HOME/Library/Preferences/$filename"
    case "$1" in
        "export")
            plutil -convert xml1 "$dst_file" -o "$i"
            ;;
        "import")
            plutil -convert binary1 "$i" -o "$dst_file"
            killall cfprefsd
            ;;
        *)
            echo "Usage: ./prefs.sh <export|import>"
            exit
            ;;
    esac
done
