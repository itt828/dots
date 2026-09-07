import { services } from "../../services"
import { pointerCursor } from "../common/cursor"
import { toggleWindow } from "../common/windows"
import { barButtonClass } from "./style"

export default function Clock() {
  return (
    <button
      {...pointerCursor}
      class={barButtonClass("module")}
      tooltipText="カレンダーとControl Center"
      onClicked={() => toggleWindow("dashboard")}
    >
      <label
        label={services.time((date) =>
          date.toLocaleString("ja-JP", {
            year: "numeric",
            month: "2-digit",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit",
          }),
        )}
      />
    </button>
  )
}
