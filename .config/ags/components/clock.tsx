import { Variable } from "astal"
const time = Variable("").poll(1000, "date")

export const Clock = () => {
  return <box className="Clock"><label label={time()} /></box>
}
