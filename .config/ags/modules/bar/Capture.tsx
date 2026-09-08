import { Gdk, Gtk } from "ags/gtk4"

import { run } from "../../services/command"
import { pointerCursor, setPointerCursor } from "../common/cursor"
import { phosphor } from "../common/icons"
import { barButtonClass } from "./style"

const captureScript = `${SRC}/scripts/capture.sh`

type CaptureAction = "screenshot" | "record"

function CaptureMenu({
  action,
  icon,
  label,
  monitor,
}: {
  action: CaptureAction
  icon: string
  label: string
  monitor: Gdk.Monitor
}) {
  let popover: Gtk.Popover
  const outputName = monitor.get_connector() ?? ""

  const invoke = (scope: "output" | "region") => {
    popover.popdown()
    run([captureScript, action, scope, outputName])
  }

  const stop = () => {
    popover.popdown()
    run([captureScript, "stop"])
  }

  return (
    <menubutton
      $={(self: Gtk.MenuButton) => setPointerCursor(self)}
      class={barButtonClass("module icon capture-button")}
      tooltipText={`${label}（範囲を選択できます）`}
    >
      <label class="phosphor-icon" label={icon} />
      <popover $={(self: Gtk.Popover) => (popover = self)} hasArrow={false}>
        <box class="capture-menu" orientation={Gtk.Orientation.VERTICAL} spacing={4}>
          <label class="capture-menu-title" xalign={0} label={label} />
          <button
            {...pointerCursor}
            class="capture-menu-item"
            onClicked={() => invoke("output")}
          >
            <box spacing={8}>
              <label class="phosphor-icon" label={phosphor.monitor} />
              <label label="この画面" />
            </box>
          </button>
          <button
            {...pointerCursor}
            class="capture-menu-item"
            onClicked={() => invoke("region")}
          >
            <box spacing={8}>
              <label class="phosphor-icon" label={phosphor.selection} />
              <label label="範囲を選択" />
            </box>
          </button>
          {action === "record" && (
            <button
              {...pointerCursor}
              class="capture-menu-item capture-stop"
              onClicked={stop}
            >
              <box spacing={8}>
                <label class="phosphor-icon" label={phosphor.stop} />
                <label label="録画を停止" />
              </box>
            </button>
          )}
        </box>
      </popover>
    </menubutton>
  )
}

export function Screenshot({ monitor }: { monitor: Gdk.Monitor }) {
  return (
    <CaptureMenu action="screenshot" icon={phosphor.camera} label="スクリーンショット" monitor={monitor} />
  )
}

export function ScreenRecording({ monitor }: { monitor: Gdk.Monitor }) {
  return (
    <CaptureMenu action="record" icon={phosphor.videoCamera} label="スクリーン録画" monitor={monitor} />
  )
}
