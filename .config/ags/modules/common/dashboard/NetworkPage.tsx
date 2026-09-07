import { Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { createPoll } from "ags/time"
import { For } from "gnim"

import { run, services } from "../../../services"
import { pointerCursor } from "../cursor"

export default function NetworkPage() {
  const networks = createPoll<{ name: string; signal: number; active: boolean }[]>(
    [],
    5_000,
    async () => {
      try {
        const raw = await execAsync([
          "nmcli",
          "-t",
          "-f",
          "IN-USE,SSID,SIGNAL",
          "device",
          "wifi",
          "list",
          "--rescan",
          "auto",
        ])
        const seen = new Set<string>()
        return raw
          .split("\n")
          .flatMap((line) => {
            const [mark, name, strength] = line.split(":")
            if (!name || seen.has(name)) return []
            seen.add(name)
            return [{ name, signal: Number(strength || 0), active: mark === "*" }]
          })
          .slice(0, 8)
      } catch {
        return []
      }
    },
  )

  return (
    <box class="page" orientation={Gtk.Orientation.VERTICAL} spacing={12}>
      <label class="section-title" xalign={0} label="Network" />
      <box class="card" spacing={12}>
        <label
          class="large-icon"
          label={services.network((network) => (network.wifi ? "◉" : "⇄"))}
        />
        <box orientation={Gtk.Orientation.VERTICAL} hexpand>
          <label
            xalign={0}
            class="card-title"
            label={services.network((network) => network.name)}
          />
          <label
            xalign={0}
            class="secondary"
            label={services.network((network) =>
              network.connected ? `${network.wifi ? "Wi-Fi" : "Ethernet"} 接続中` : "未接続",
            )}
          />
        </box>
        <switch
          active={services.network((network) => network.enabled)}
          onStateSet={(_, enabled) => {
            run(["nmcli", "radio", "wifi", enabled ? "on" : "off"])
            return false
          }}
        />
      </box>
      <label class="secondary" xalign={0} label="利用可能な Wi-Fi" />
      <box orientation={Gtk.Orientation.VERTICAL} spacing={5}>
        <For each={networks} id={(network) => network.name}>
          {(network) => (
            <button
              {...pointerCursor}
              class={`action-button list-item ${network.active ? "list-item-active" : ""}`}
              onClicked={() => run(["nmcli", "connection", "up", "id", network.name])}
            >
              <box spacing={8}>
                <label label={network.active ? "✓" : "○"} />
                <label xalign={0} hexpand label={network.name} />
                <label label={`${network.signal}%`} />
              </box>
            </button>
          )}
        </For>
      </box>
    </box>
  )
}
