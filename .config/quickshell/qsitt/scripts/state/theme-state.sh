#!/bin/sh
set -eu

dir="${XDG_STATE_HOME:-$HOME/.local/state}/qsitt"

case "${1:-}" in
    load-theme)
        [ ! -f "$dir/theme" ] || cat -- "$dir/theme"
        ;;
    load-mode)
        [ ! -f "$dir/mode" ] || cat -- "$dir/mode"
        ;;
    save-theme|save-mode)
        [ "$#" -eq 2 ] || exit 2
        case "$1" in
            save-theme)
                case "$2" in
                    ''|*[!a-z0-9_-]*) exit 2 ;;
                esac
                file="$dir/theme"
                ;;
            save-mode)
                case "$2" in
                    light|dark) ;;
                    *) exit 2 ;;
                esac
                file="$dir/mode"
                ;;
        esac
        mkdir -p -- "$dir"
        tmp=$(mktemp "$dir/.theme.XXXXXX")
        trap 'rm -f -- "$tmp"' EXIT HUP INT TERM
        printf '%s\n' "$2" > "$tmp"
        mv -f -- "$tmp" "$file"
        trap - EXIT HUP INT TERM
        ;;
    *)
        echo 'usage: theme-state.sh load-theme|load-mode|save-theme <id>|save-mode light|dark' >&2
        exit 2
        ;;
esac
