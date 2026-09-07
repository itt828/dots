import { Astal, Gdk } from "ags/gtk4"
import app from "ags/gtk4/app"

import { config, type BarModule } from "../common/config"
import { barModules } from "./registry"

function ModuleSlot({ name, monitor }: { name: BarModule; monitor: Gdk.Monitor }) {
  const Component = barModules[name]
  return <Component monitor={monitor} />
}

function ModuleRow({ names, monitor }: { names: BarModule[]; monitor: Gdk.Monitor }) {
  return (
    <box spacing={8}>
      {names.map((name) => (
        <ModuleSlot name={name} monitor={monitor} />
      ))}
    </box>
  )
}

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor
  return (
    <window
      visible
      name={`bar-${gdkmonitor.get_connector() ?? "monitor"}`}
      class="Bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
    >
      <centerbox
        class={`bar-shell ${config.barDesign === "minimal"
            ? "bar-shell-minimal"
            : config.barDesign === "kawaii"
              ? "bar-shell-kawaii"
              : ""
          }`}
      >
        <ModuleRow $type="start" names={config.barLayout.left} monitor={gdkmonitor} />
        <ModuleRow $type="center" names={config.barLayout.center} monitor={gdkmonitor} />
        <ModuleRow $type="end" names={config.barLayout.right} monitor={gdkmonitor} />
      </centerbox>
    </window>
  )
}
