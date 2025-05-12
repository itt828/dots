import { bind } from "astal"
import { Gdk } from "astal/gtk4"
import AstalBattery from "gi://AstalBattery"
import AstalRiver from "gi://AstalRiver"

export const Monitor = ({ gdkmonitor }: { gdkmonitor: Gdk.Monitor }) => {
    const river = AstalRiver.get_default()!


    return <box cssClasses={bind(river, "focused_output").as(v => {
        if (v === gdkmonitor.get_connector())
            return ["Monitor", "Focused"]
        else
            return ["Monitor"]
    })} spacing={8}>
        <label label={gdkmonitor.get_connector()} />
    </box>
}
