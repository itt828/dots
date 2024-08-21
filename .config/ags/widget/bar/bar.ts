import { battery } from "./battery";
import { clock } from "./clock";
import { network } from "./network";
import { workspace } from "./workspace";

export const barMonitorNum = Variable(0)
globalThis.barMonitorNum = barMonitorNum

export const bar = () => Widget.Window({
  name: `bar`,
  class_name: 'bar',
  monitor: barMonitorNum.bind(),
  anchor: ['top', 'left', 'right'],
  exclusivity: 'exclusive',
  child: Widget.CenterBox({
    startWidget: workspace(5),
    centerWidget: clock(),
    endWidget: Widget.Box({
      hpack: "end",
      spacing: 12,
      css: "padding-right: 8px;",
      children: [
        network(),
        battery(),
        Widget.Label({ label: barMonitorNum.bind().as(v => v.toString()) })
      ]
    })
  }
  )
})
