import { bind } from "astal"
import MyBrightness from "./mybrightness"
export const Brightness = () => {
  const brightness = MyBrightness.get_default()

  return <box spacing={8} className="Brightness">
    <icon icon="display-brightness-symbolic" />
    <label label={bind(brightness, "screen").as(v => `${Math.floor(v * 100)}%`)} />
  </box>
}
