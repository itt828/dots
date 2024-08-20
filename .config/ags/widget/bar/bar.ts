import { battery } from "./battery";
import { clock } from "./clock";
import { workspace } from "./workspace";

export const bar = () => Widget.Window({
  name: `bar`,
  class_name: 'bar',
  monitor: 0,
  anchor: ['top', 'left', 'right'],
  exclusivity: 'exclusive',
  child: Widget.CenterBox({
    startWidget: workspace(5),
    centerWidget: clock(),
    endWidget: battery()
  }
  )
})
