import { bind } from "astal"
import AstalRiver from "gi://AstalRiver?version=0.1"

export const Output = ({ connector }: { connector: string }) => {
    const river = AstalRiver.get_default()!
    const output = river.get_output(connector)

    // <label label={} />
    return <box cssClasses={["Output"]}>
        <label label={bind(river, "focused_view").as(truncate)} />
    </box>
}

const truncate = (text: string) => {
    const maxLength = 20
    if (text.length <= maxLength) return text
    return text.slice(0, maxLength / 2) + " ... " + text.slice(text.length - maxLength / 2)

}