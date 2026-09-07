import { Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { createPoll } from "ags/time"
import { createComputed, createState } from "gnim"

import { pointerCursor } from "../cursor"
import { toggleWindow } from "../windows"

function formatDuration(seconds: number) {
  const value = Math.max(0, Math.floor(seconds))
  return `${String(Math.floor(value / 60)).padStart(2, "0")}:${String(value % 60).padStart(2, "0")}`
}

function TimerStopwatch() {
  const now = createPoll(Date.now(), 100, () => Date.now())
  const [duration, setDuration] = createState(300)
  const [deadline, setDeadline] = createState(0)
  const [elapsed, setElapsed] = createState(0)
  const [started, setStarted] = createState(0)
  const timerText = createComputed(() =>
    formatDuration(deadline() ? (deadline() - now()) / 1000 : duration()),
  )
  const stopwatchText = createComputed(() =>
    formatDuration((elapsed() + (started() ? now() - started() : 0)) / 1000),
  )

  return (
    <box class="timers" orientation={Gtk.Orientation.VERTICAL} spacing={8}>
      <box class="card" spacing={8}>
        <box orientation={Gtk.Orientation.VERTICAL} hexpand>
          <label xalign={0} class="card-title" label="タイマー" />
          <label xalign={0} class="timer-value" label={timerText} />
        </box>
        {[1, 5, 10].map((minutes) => (
          <button
            {...pointerCursor}
            class="action-button"
            onClicked={() => {
              setDuration(minutes * 60)
              setDeadline(0)
            }}
          >
            <label label={`${minutes}分`} />
          </button>
        ))}
        <button
          {...pointerCursor}
          class="action-button"
          onClicked={() => setDeadline(deadline.peek() ? 0 : Date.now() + duration.peek() * 1000)}
        >
          <label label={deadline((value) => (value ? "停止" : "開始"))} />
        </button>
      </box>
      <box class="card" spacing={8}>
        <box orientation={Gtk.Orientation.VERTICAL} hexpand>
          <label xalign={0} class="card-title" label="ストップウォッチ" />
          <label xalign={0} class="timer-value" label={stopwatchText} />
        </box>
        <button
          {...pointerCursor}
          class="action-button"
          onClicked={() => {
            if (started.peek()) {
              setElapsed((value) => value + Date.now() - started.peek())
              setStarted(0)
            } else setStarted(Date.now())
          }}
        >
          <label label={started((value) => (value ? "停止" : "開始"))} />
        </button>
        <button
          {...pointerCursor}
          class="action-button"
          onClicked={() => {
            setStarted(0)
            setElapsed(0)
          }}
        >
          <label label="リセット" />
        </button>
      </box>
    </box>
  )
}

export default function ToolsPage() {
  const [status, setStatus] = createState("画面上の範囲または色を選択できます")
  const selectQr = async () => {
    toggleWindow("dashboard")
    setStatus("QRコードを読み取り中…")
    try {
      const result = await execAsync([
        "sh",
        "-c",
        'geometry=$(slurp) && grim -g "$geometry" -t png - | zbarimg --quiet --raw - | tee >(wl-copy)',
      ])
      setStatus(result ? `${result} をコピーしました` : "QRコードが見つかりません")
    } catch {
      setStatus("QRコードの読み取りをキャンセルしました")
    }
    toggleWindow("dashboard")
  }
  const pickColor = async () => {
    toggleWindow("dashboard")
    setStatus("色を取得中…")
    try {
      const result = await execAsync([
        "sh",
        "-c",
        "geometry=$(slurp -p -f '%x,%y 1x1') && grim -g \"$geometry\" -t png - | magick png:- -alpha off -depth 8 -format '#%[hex:p{0,0}]' info:- | tee >(wl-copy)",
      ])
      setStatus(`${result} をコピーしました`)
    } catch {
      setStatus("色の選択をキャンセルしました")
    }
    toggleWindow("dashboard")
  }

  return (
    <box class="page" orientation={Gtk.Orientation.VERTICAL} spacing={10}>
      <label class="section-title" xalign={0} label="Tools" />
      <button {...pointerCursor} class="tool-card" onClicked={selectQr}>
        <box spacing={12}>
          <label class="tool-badge" label="QR" />
          <label xalign={0} hexpand label="QRコードを範囲から読み取る" />
        </box>
      </button>
      <button {...pointerCursor} class="tool-card" onClicked={pickColor}>
        <box spacing={12}>
          <label class="tool-badge" label="◉" />
          <label xalign={0} hexpand label="カラーピッカー" />
        </box>
      </button>
      <label class="secondary" xalign={0} wrap label={status} />
      <TimerStopwatch />
    </box>
  )
}
