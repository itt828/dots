import { Gdk } from "ags/gtk4"

import { type BarModule } from "../common/config"
import Battery from "./Battery"
import Brightness from "./Brightness"
import { ScreenRecording, Screenshot } from "./Capture"
import Clock from "./Clock"
import Cpu from "./Cpu"
import Memory from "./Memory"
import Microphone from "./Microphone"
import Network from "./Network"
import Notifications from "./Notifications"
import Power from "./Power"
import Search from "./Search"
import Tray from "./Tray"
import Volume from "./Volume"
import WindowTitle from "./WindowTitle"
import Workspaces from "./Workspaces"

export type BarModuleComponent = (props: { monitor: Gdk.Monitor }) => JSX.Element

export const barModules = {
  search: Search,
  workspaces: Workspaces,
  windowTitle: WindowTitle,
  clock: Clock,
  tray: Tray,
  notifications: Notifications,
  screenshot: Screenshot,
  screenRecording: ScreenRecording,
  volume: Volume,
  microphone: Microphone,
  brightness: Brightness,
  cpu: Cpu,
  memory: Memory,
  network: Network,
  battery: Battery,
  power: Power,
} as Record<BarModule, BarModuleComponent>
