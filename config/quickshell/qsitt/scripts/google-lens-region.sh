#!/usr/bin/env bash

set -euo pipefail

notify_error() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Google Lens" "$1"
  else
    printf 'Google Lens: %s\n' "$1" >&2
  fi
}

for required_command in grim base64 xdg-open; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    notify_error "$required_command が見つかりません"
    exit 1
  fi
done

image_path=$(mktemp "${TMPDIR:-/tmp}/qsitt-lens.XXXXXX.png")
upload_page=$(mktemp "${TMPDIR:-/tmp}/qsitt-lens.XXXXXX.html")

cleanup() {
  rm -f -- "$image_path" "$upload_page"
}
trap cleanup EXIT

geometry=${1:-}
if [[ -z "$geometry" ]]; then
  if ! command -v slurp >/dev/null 2>&1; then
    notify_error "slurp が見つかりません"
    exit 1
  fi
  geometry=$(slurp -d -b '#10182066' -c '#0078d4ff' -s '#0078d433' -w 3) || exit 0
fi
[[ -n "$geometry" ]] || exit 0
grim -g "$geometry" "$image_path"

image_data=$(base64 -w 0 "$image_path")
dimensions=${geometry##* }
dimensions=${dimensions/x/,}
timestamp=$(date +%s%3N)

printf '%s\n' \
  '<!doctype html>' \
  '<meta charset="utf-8">' \
  '<title>Google Lensへ送信中</title>' \
  '<p>Google Lensへ送信しています…</p>' \
  '<script>' \
  '(async () => {' \
  '  const response = await fetch("data:image/png;base64,'"$image_data"'")' \
  '  const file = new File([await response.blob()], "capture.png", { type: "image/png" })' \
  '  const transfer = new DataTransfer()' \
  '  transfer.items.add(file)' \
  '  const form = document.createElement("form")' \
  '  form.method = "POST"' \
  '  form.enctype = "multipart/form-data"' \
  '  form.action = "https://lens.google.com/v3/upload?ep=ccm&s=&st='"$timestamp"'"' \
  '  const image = document.createElement("input")' \
  '  image.type = "file"' \
  '  image.name = "encoded_image"' \
  '  image.files = transfer.files' \
  '  form.appendChild(image)' \
  '  const size = document.createElement("input")' \
  '  size.type = "hidden"' \
  '  size.name = "processed_image_dimensions"' \
  '  size.value = "'"$dimensions"'"' \
  '  form.appendChild(size)' \
  '  document.body.appendChild(form)' \
  '  form.submit()' \
  '})().catch((error) => {' \
  '  document.body.textContent = `Google Lensへの送信に失敗しました: ${error}`' \
  '})' \
  '</script>' >"$upload_page"

xdg-open "$upload_page"

# xdg-open may return before the browser reads the temporary page.
sleep 5
