#!/usr/bin/env bash

set -u

action=${1:-}
scope=${2:-}
output_name=${3:-}

runtime_dir=${XDG_RUNTIME_DIR:-/tmp}
recording_pid_file="$runtime_dir/ags-screen-recording.pid"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$@"
  fi
}

user_dir() {
  local kind=$1
  local fallback=$2
  local resolved=""

  if command -v xdg-user-dir >/dev/null 2>&1; then
    resolved=$(xdg-user-dir "$kind" 2>/dev/null || true)
  fi

  if [[ -n "$resolved" ]]; then
    printf '%s\n' "$resolved"
  else
    printf '%s\n' "$fallback"
  fi
}

recording_pid() {
  [[ -r "$recording_pid_file" ]] || return 1

  local pid
  pid=$(<"$recording_pid_file")
  [[ "$pid" =~ ^[0-9]+$ ]] || return 1
  kill -0 "$pid" 2>/dev/null || return 1
  printf '%s\n' "$pid"
}

select_geometry() {
  slurp -d
}

capture_screenshot() {
  local geometry=""
  local pictures_dir
  local screenshot_dir
  local screenshot_path

  pictures_dir=$(user_dir PICTURES "$HOME/Pictures")
  screenshot_dir="$pictures_dir/Screenshots"
  mkdir -p "$screenshot_dir"
  screenshot_path="$screenshot_dir/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"

  case "$scope" in
    output)
      [[ -n "$output_name" ]] || {
        notify -u critical "スクリーンショット" "画面を特定できませんでした"
        return 1
      }
      grim -o "$output_name" "$screenshot_path"
      ;;
    region)
      geometry=$(select_geometry) || return 0
      grim -g "$geometry" "$screenshot_path"
      ;;
    *)
      return 2
      ;;
  esac

  notify "スクリーンショットを保存しました" "$screenshot_path"
}

start_recording() {
  local geometry=""
  local videos_dir
  local recording_dir
  local recording_path
  local recorder_pid
  local -a recorder_args

  if recording_pid >/dev/null; then
    notify -u normal "スクリーン録画" "すでに録画中です"
    return 0
  fi

  case "$scope" in
    output)
      [[ -n "$output_name" ]] || {
        notify -u critical "スクリーン録画" "画面を特定できませんでした"
        return 1
      }
      recorder_args=(-o "$output_name")
      ;;
    region)
      geometry=$(select_geometry) || return 0
      recorder_args=(-g "$geometry")
      ;;
    *)
      return 2
      ;;
  esac

  videos_dir=$(user_dir VIDEOS "$HOME/Videos")
  recording_dir="$videos_dir/Recordings"
  mkdir -p "$recording_dir"
  recording_path="$recording_dir/Recording from $(date '+%Y-%m-%d %H-%M-%S').mp4"

  wf-recorder "${recorder_args[@]}" -f "$recording_path" &
  recorder_pid=$!
  printf '%s\n' "$recorder_pid" >"$recording_pid_file"

  cleanup() {
    if [[ -r "$recording_pid_file" ]] && [[ "$(<"$recording_pid_file")" == "$recorder_pid" ]]; then
      rm -f "$recording_pid_file"
    fi
  }
  trap cleanup EXIT

  notify "スクリーン録画を開始しました" "停止はバーの録画メニューから行えます"
  if wait "$recorder_pid"; then
    notify "スクリーン録画を保存しました" "$recording_path"
  else
    local status=$?
    if [[ $status -ne 130 ]]; then
      notify -u critical "スクリーン録画に失敗しました" "$recording_path"
      return "$status"
    fi
    notify "スクリーン録画を保存しました" "$recording_path"
  fi
}

stop_recording() {
  local pid
  if ! pid=$(recording_pid); then
    rm -f "$recording_pid_file"
    notify -u normal "スクリーン録画" "録画中ではありません"
    return 0
  fi

  kill -INT "$pid"
}

case "$action" in
  screenshot)
    capture_screenshot
    ;;
  record)
    start_recording
    ;;
  stop)
    stop_recording
    ;;
  *)
    printf 'usage: %s screenshot|record output|region [output-name]\n' "$0" >&2
    printf '       %s stop\n' "$0" >&2
    exit 2
    ;;
esac
