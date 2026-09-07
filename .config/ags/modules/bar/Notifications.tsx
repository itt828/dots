import { createComputed } from "gnim"

import { doNotDisturb, notifications } from "../../services"
import { pointerCursor } from "../common/cursor"
import { phosphor } from "../common/icons"
import { toggleWindow } from "../common/windows"
import { barButtonClass } from "./style"

export default function Notifications() {
  return (
    <button
      {...pointerCursor}
      class={barButtonClass("module")}
      tooltipText="通知 / DND: ダッシュボードで変更"
      onClicked={() => toggleWindow("dashboard")}
    >
      <box spacing={6}>
        <label
          class="phosphor-icon"
          label={createComputed(() =>
            doNotDisturb()
              ? phosphor.bellSlash
              : notifications().length
                ? phosphor.bellRinging
                : phosphor.bell,
          )}
        />
        <label label={notifications((items) => String(items.length))} />
      </box>
    </button>
  )
}
