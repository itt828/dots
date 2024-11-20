import { bluetooth } from "./bluetooth";
import { cpu } from "./cpu";
import { Light } from "./light";
import { mem } from "./mem";
import { notifications } from "./notification";
import { volume } from "./volume";

export const menu = () => Widget.Window({
  name: "menu",
  visible: false,
  anchor: ["top", "right"],
  margins: [8,8,0,0],
  widthRequest: 500,
  child: Widget.Box({
    vertical: true,
    children: [
      Light(),
      volume(),
      bluetooth(),
      mem(),
      cpu(),
      notifications()
    
    ]
  })

})
