import { pointerCursor } from "../common/cursor"
import { phosphor } from "../common/icons"
import { toggleWindow } from "../common/windows"
import { barButtonClass } from "./style"

export default function Search() {
  return (
    <button
      {...pointerCursor}
      class={barButtonClass("module icon")}
      tooltipText="Web検索"
      onClicked={() => toggleWindow("search")}
    >
      <label class="phosphor-icon" label={phosphor.search} />
    </button>
  )
}
