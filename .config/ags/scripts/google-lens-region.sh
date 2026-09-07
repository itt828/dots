#!/usr/bin/env bash

set -euo pipefail

notify_error() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Google Lens" "$1"
  else
    printf 'Google Lens: %s\n' "$1" >&2
  fi
}

for command in slurp grim base64 xdg-open; do
  if ! command -v "$command" >/dev/null 2>&1; then
    notify_error "$command が見つかりません"
    exit 1
  fi
done

image_path=$(mktemp "${TMPDIR:-/tmp}/ags-lens.XXXXXX.png")
upload_page=$(mktemp "${TMPDIR:-/tmp}/ags-lens.XXXXXX.html")
cleanup() {
  rm -f -- "$image_path" "$upload_page"
}
trap cleanup EXIT

# Give the search window a moment to disappear before taking the screenshot.
sleep 0.15
geometry=$(slurp) || exit 0
[[ -n "$geometry" ]] || exit 0
grim -g "$geometry" "$image_path"

image_data=$(base64 -w 0 "$image_path")
# slurp returns "x,y widthxheight". Google Lens expects the latter as
# "width,height" in processed_image_dimensions.
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

# xdg-open can return before the browser has finished reading the local page.
sleep 5
