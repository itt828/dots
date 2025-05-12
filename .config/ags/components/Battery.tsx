import { bind } from "astal"
import AstalBattery from "gi://AstalBattery"

export const Battery = () => {
    const bat = AstalBattery.get_default()

    return <box cssClasses={["Battery"]}
        spacing={8}
        visible={bind(bat, "isPresent")}>
        <image iconName={bind(bat, "batteryIconName")} />
        <label label={bind(bat, "percentage").as(p =>
            `${Math.floor(p * 100)} %`
        )} />
    </box>
}
