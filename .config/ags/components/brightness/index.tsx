import { bind } from "astal"
import MyBrightness from "./mybrightness"
export const Brightness = () => {
    const brightness = MyBrightness.get_default()

    return <box spacing={8} cssName="Brightness">
        <image iconName="display-brightness-symbolic" />
        <label label={bind(brightness, "screen").as(v => `${Math.round(v * 100)}%`)} />
    </box>
}
