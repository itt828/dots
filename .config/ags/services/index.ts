import { microphone, volume } from "./audio"
import { brightness } from "./brightness"
import { niri } from "./niri"
import { battery, cpu, memory, network, time } from "./system"

export * from "./audio"
export * from "./brightness"
export * from "./command"
export * from "./notifications"
export * from "./system"
export * from "./tray"
export type { Workspace } from "./niri"

export const services = {
  time,
  workspaces: niri.workspaces,
  windowTitle: niri.windowTitle,
  volume,
  microphone,
  brightness,
  cpu,
  memory,
  network,
  battery,
}
