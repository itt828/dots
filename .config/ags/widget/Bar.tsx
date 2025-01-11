import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Battery } from "../components/battery"
import { Tray } from "../components/tray"
import { Clock } from "../components/clock"
import { Network } from "../components/network"
import { Notification } from "../components/notification"
import { Volume } from "../components/volume"
import { Brightness } from "../components/brightness"




export default function Bar(gdkmonitor: Gdk.Monitor) {
  return <window
    className="Bar"
    gdkmonitor={gdkmonitor}
    exclusivity={Astal.Exclusivity.EXCLUSIVE}
    anchor={Astal.WindowAnchor.TOP
      | Astal.WindowAnchor.LEFT
      | Astal.WindowAnchor.RIGHT}
    application={App}>
    <box spacing={8}>
      <Clock />
      <Tray />
      <Battery />
      <Network />
      <Notification />
      <Volume />
      <Brightness />
    </box>
  </window>
}
