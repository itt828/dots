#!/bin/sh
set -eu

dir="${XDG_CONFIG_HOME:-$HOME/.config}/qsitt"
file="$dir/settings.json"

case "${1:-}" in
    load)
        [ ! -f "$file" ] || cat -- "$file"
        ;;
    save)
        [ "$#" -eq 2 ] || exit 2
        mkdir -p -- "$dir"
        tmp=$(mktemp "$dir/.settings.XXXXXX")
        trap 'rm -f -- "$tmp"' EXIT HUP INT TERM
        printf '%s\n' "$2" > "$tmp"
        mv -f -- "$tmp" "$file"
        trap - EXIT HUP INT TERM
        ;;
    *)
        echo 'usage: settings-state.sh load|save <json>' >&2
        exit 2
        ;;
esac
