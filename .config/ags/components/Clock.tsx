import { Variable } from "astal"
const time = Variable("").poll(1000, "date '+%-m/%-d(%a) %H:%M:%S'")

export const Clock = () => {
    return <box cssClasses={["bg-[#abc123]"]}>
        <label label={time()} />
    </box>
}
