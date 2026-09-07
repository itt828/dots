import { Astal, Gdk, Gtk } from "ags/gtk4"
import app from "ags/gtk4/app"

import { run } from "../../../services"
import { pointerCursor } from "../cursor"
import { toggleWindow } from "../windows"

const options = [
  ["🔒", "ロック", ["loginctl", "lock-session"]],
  ["◐", "サスペンド", ["systemctl", "suspend"]],
  ["⇥", "ログアウト", ["niri", "msg", "action", "quit"]],
  ["↻", "再起動", ["systemctl", "reboot"]],
  ["⏻", "シャットダウン", ["systemctl", "poweroff"]],
] as const

export default function PowerMenu(gdkmonitor: Gdk.Monitor) {
  const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor
  return (
    <window
      name="power-menu"
      class="PowerMenu"
      visible={false}
      gdkmonitor={gdkmonitor}
      application={app}
      anchor={TOP | BOTTOM | LEFT | RIGHT}
      layer={Astal.Layer.OVERLAY}
      keymode={Astal.Keymode.EXCLUSIVE}
      exclusivity={Astal.Exclusivity.IGNORE}
    >
      <box halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
        <box class="power-card" orientation={Gtk.Orientation.VERTICAL} spacing={16}>
          <label class="text-20 font-bold" label="セッション" />
          <box spacing={12}>
            {options.map(([icon, label, command]) => (
              <button
                {...pointerCursor}
                class="action-button power-option"
                onClicked={() => {
                  toggleWindow("power-menu")
                  run([...command])
                }}
              >
                <box orientation={Gtk.Orientation.VERTICAL} spacing={8}>
                  <label class="power-icon" label={icon} />
                  <label label={label} />
                </box>
              </button>
            ))}
          </box>
          <button
            {...pointerCursor}
            class="action-button"
            onClicked={() => toggleWindow("power-menu")}
          >
            <label label="キャンセル" />
          </button>
        </box>
      </box>
    </window>
  )
}
