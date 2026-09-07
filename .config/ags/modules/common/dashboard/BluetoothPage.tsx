import { Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { createPoll } from "ags/time"
import { For } from "gnim"

import { run } from "../../../services"
import { pointerCursor } from "../cursor"

export default function BluetoothPage() {
  const enabled = createPoll(false, 2_000, async () => {
    try {
      return (await execAsync(["rfkill", "list", "bluetooth"])).includes("Soft blocked: no")
    } catch {
      return false
    }
  })
  const devices = createPoll<{ address: string; name: string; connected: boolean }[]>(
    [],
    4_000,
    async () => {
      try {
        const [all, connected] = await Promise.all([
          execAsync(["bluetoothctl", "devices"]),
          execAsync(["bluetoothctl", "devices", "Connected"]),
        ])
        const connectedAddresses = new Set(connected.split("\n").map((line) => line.split(" ")[1]))
        return all
          .split("\n")
          .filter(Boolean)
          .map((line) => {
            const [, address, ...name] = line.split(" ")
            return { address, name: name.join(" "), connected: connectedAddresses.has(address) }
          })
          .slice(0, 8)
      } catch {
        return []
      }
    },
  )

  return (
    <box class="page" orientation={Gtk.Orientation.VERTICAL} spacing={12}>
      <label class="section-title" xalign={0} label="Bluetooth" />
      <box class="card" spacing={12}>
        <label class="large-icon" label="B" />
        <label
          xalign={0}
          hexpand
          label={enabled((on) => (on ? "Bluetooth は有効です" : "Bluetooth は無効です"))}
        />
        <switch
          active={enabled}
          onStateSet={(_, on) => {
            run(["rfkill", on ? "unblock" : "block", "bluetooth"])
            return false
          }}
        />
      </box>
      <box orientation={Gtk.Orientation.VERTICAL} spacing={5}>
        <For each={devices} id={(device) => device.address}>
          {(device) => (
            <button
              {...pointerCursor}
              class={`action-button list-item ${device.connected ? "list-item-active" : ""}`}
              onClicked={() =>
                run(["bluetoothctl", device.connected ? "disconnect" : "connect", device.address])
              }
            >
              <box spacing={8}>
                <label label={device.connected ? "●" : "B"} />
                <label xalign={0} hexpand label={device.name || device.address} />
                <label class="secondary" label={device.connected ? "切断" : "接続"} />
              </box>
            </button>
          )}
        </For>
      </box>
    </box>
  )
}
