#!/usr/bin/env bash

set -euo pipefail

if ! command -v gi-decompile-typelib >/dev/null 2>&1; then
  echo "error: gi-decompile-typelib is required" >&2
  exit 1
fi

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/ags-types.XXXXXX")
gir_dir="$temp_dir/gir-1.0"
mkdir -p "$gir_dir"

cleanup() {
  rm -rf -- "$temp_dir"
}
trap cleanup EXIT

typelib_dirs=(
  /usr/lib64/girepository-1.0
  /usr/lib/girepository-1.0
  /usr/lib/x86_64-linux-gnu/girepository-1.0
)

shopt -s nullglob
typelibs=()
for typelib_dir in "${typelib_dirs[@]}"; do
  typelibs+=("$typelib_dir"/Astal*.typelib)
done

if (( ${#typelibs[@]} == 0 )); then
  echo "error: no Astal typelibs were found" >&2
  exit 1
fi

for typelib in "${typelibs[@]}"; do
  module=$(basename -- "$typelib" .typelib)
  [[ -e "$gir_dir/$module.gir" ]] && continue
  gi-decompile-typelib \
    --all \
    --output="$gir_dir/$module.gir" \
    "$typelib"
done

cd "$project_dir"
pnpm exec ts-for-gir generate \
  'Astal*' \
  --ignoreVersionConflicts \
  --outdir "$project_dir/@girs" \
  --girDirectories "$gir_dir" /usr/local/share/gir-1.0 /usr/share/gir-1.0
