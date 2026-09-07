import { pointerCursor } from "../common/cursor"
import { phosphor } from "../common/icons"
import { toggleWindow } from "../common/windows"
import { barButtonClass } from "./style"

export default function Power() {
  return (
    <button
      {...pointerCursor}
      class={barButtonClass("module icon")}
      tooltipText="電源メニュー"
      onClicked={() => toggleWindow("power-menu")}
    >
      <label class="phosphor-icon" label={phosphor.power} />
    </button>
  )
}
