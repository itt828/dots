#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: generate-palette.sh [options] IMAGE [PALETTE_NAME]

Generate modules/common/theme/palettes/<name>.toml from an image with matugen.

Options:
  -f, --force               Overwrite an existing palette
  -t, --type TYPE           matugen scheme type (default: scheme-tonal-spot)
  -i, --source-index INDEX  Source color index from 0 to 4 (default: 0)
  -h, --help                Show this help
EOF
}

fail() {
    printf 'generate-palette: %s\n' "$*" >&2
    exit 1
}

force=false
scheme_type="scheme-tonal-spot"
source_index=0

while (($# > 0)); do
    case "$1" in
        -f|--force)
            force=true
            shift
            ;;
        -t|--type)
            (($# >= 2)) || fail "$1 requires a value"
            scheme_type=$2
            shift 2
            ;;
        -i|--source-index)
            (($# >= 2)) || fail "$1 requires a value"
            source_index=$2
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        -*)
            fail "unknown option: $1"
            ;;
        *)
            break
            ;;
    esac
done

(($# >= 1 && $# <= 2)) || {
    usage >&2
    exit 2
}

image_path=$1
palette_name=${2:-}

[[ -f "$image_path" ]] || fail "image not found: $image_path"
[[ "$source_index" =~ ^[0-4]$ ]] || fail "source index must be between 0 and 4"
command -v matugen >/dev/null 2>&1 || fail "matugen is not installed"
command -v jq >/dev/null 2>&1 || fail "jq is not installed"

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
palette_dir="$project_dir/modules/common/theme/palettes"

if [[ -z "$palette_name" ]]; then
    image_name=$(basename -- "$image_path")
    palette_name=${image_name%.*}
    palette_name=$(printf '%s' "$palette_name" \
        | tr '[:upper:]' '[:lower:]' \
        | sed -E 's/[^a-z0-9_-]+/-/g; s/^[-_]+//; s/[-_]+$//')
fi

[[ "$palette_name" =~ ^[a-z0-9][a-z0-9_-]*$ ]] \
    || fail "palette name must contain only lowercase letters, numbers, '-' or '_'"

output_path="$palette_dir/$palette_name.toml"
if [[ -e "$output_path" && "$force" != true ]]; then
    fail "palette already exists: $output_path (use --force to overwrite)"
fi

json_file=$(mktemp)
toml_file=$(mktemp "$palette_dir/.${palette_name}.toml.XXXXXX")
cleanup() {
    rm -f -- "$json_file" "$toml_file"
}
trap cleanup EXIT

matugen image "$image_path" \
    --type "$scheme_type" \
    --source-color-index "$source_index" \
    --mode light \
    --json hex \
    --dry-run >"$json_file"

jq -e '
    def required: [
        "background", "surface", "surface_variant", "surface_container_low",
        "surface_container", "surface_container_high", "primary",
        "primary_container", "on_primary", "on_surface", "on_surface_variant",
        "outline", "outline_variant", "secondary", "error", "tertiary"
    ];
    . as $root
    | all(required[]; $root.colors[.].light.color and $root.colors[.].dark.color)
' "$json_file" >/dev/null || fail "matugen output did not contain all required colors"

jq -r '
    def color($name; $mode): .colors[$name][$mode].color;
    def line($name; $source; $mode): $name + " = \"" + color($source; $mode) + "\"";
    def section($mode):
        "[" + $mode + "]",
        line("background"; "background"; $mode),
        line("surface"; "surface"; $mode),
        line("surfaceVariant"; "surface_variant"; $mode),
        line("surfaceContainerLow"; "surface_container_low"; $mode),
        line("surfaceContainer"; "surface_container"; $mode),
        line("surfaceContainerHigh"; "surface_container_high"; $mode),
        line("primary"; "primary"; $mode),
        line("primaryContainer"; "primary_container"; $mode),
        line("primaryText"; "on_primary"; $mode),
        line("text"; "on_surface"; $mode),
        line("textSecondary"; "on_surface_variant"; $mode),
        line("outline"; "outline"; $mode),
        line("outlineVariant"; "outline_variant"; $mode),
        line("accent"; "secondary"; $mode),
        line("danger"; "error"; $mode),
        line("success"; "tertiary"; $mode);
    section("light"), "", section("dark")
' "$json_file" >"$toml_file"

mv -- "$toml_file" "$output_path"
printf 'Generated %s\n' "$output_path"
