import { createPoll } from "ags/time"

import { output } from "./command"

export type NetworkState = {
  connected: boolean
  wifi: boolean
  enabled: boolean
  name: string
  signal: number
}

export type BatteryState = { present: boolean; percentage: number; charging: boolean }

export const time = createPoll(new Date(), 1_000, () => new Date())

export const cpu = createPoll("-", 2_000, async () => {
  const raw = await output(["cat", "/proc/loadavg"])
  return raw.trim().split(/\s+/)[0] || "-"
})

export const memory = createPoll("-", 5_000, async () => {
  const raw = await output(["free", "-b"])
  const values = raw
    .split("\n")
    .find((line) => line.startsWith("Mem:"))
    ?.trim()
    .split(/\s+/)
  if (!values || Number(values[1]) === 0) return "-"
  return `${Math.round((Number(values[2]) / Number(values[1])) * 100)}%`
})

export const network = createPoll<NetworkState>(
  { connected: false, wifi: false, enabled: false, name: "Disconnected", signal: 0 },
  2_000,
  async () => {
    const radio = (await output(["nmcli", "radio", "wifi"], "disabled")).trim() === "enabled"
    const raw = await output([
      "nmcli",
      "-t",
      "-f",
      "TYPE,NAME,DEVICE",
      "connection",
      "show",
      "--active",
    ])
    const rows = raw.split("\n").filter(Boolean)
    const active =
      rows.find((row) => row.startsWith("802-11-wireless:")) ??
      rows.find((row) => row.startsWith("802-3-ethernet:"))
    if (!active) {
      return { connected: false, wifi: false, enabled: radio, name: "Disconnected", signal: 0 }
    }
    const [type, name] = active.split(":")
    const wifi = type === "802-11-wireless"
    const signalRaw = wifi
      ? await output(["nmcli", "-t", "-f", "IN-USE,SIGNAL", "device", "wifi", "list"])
      : ""
    const signal = Number(
      signalRaw
        .split("\n")
        .find((row) => row.startsWith("*:"))
        ?.split(":")[1] ?? 100,
    )
    return { connected: true, wifi, enabled: radio, name: name || "Connected", signal }
  },
)

export const battery = createPoll<BatteryState>(
  { present: false, percentage: 0, charging: false },
  10_000,
  async () => {
    const device = (await output(["sh", "-c", "upower -e | grep -m1 battery"])).trim()
    if (!device) return { present: false, percentage: 0, charging: false }
    const raw = await output(["upower", "-i", device])
    const percentage = Number(raw.match(/percentage:\s+(\d+)%/)?.[1] ?? 0)
    const state = raw.match(/state:\s+([^\n]+)/)?.[1]?.trim() ?? ""
    return {
      present: true,
      percentage,
      charging: state === "charging" || state === "fully-charged",
    }
  },
)
