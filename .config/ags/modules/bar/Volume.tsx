import { services, toggleVolumeMute } from "../../services"
import { pointerCursor } from "../common/cursor"
import { phosphor } from "../common/icons"
import { createFlash } from "./flash"
import { barButtonClass } from "./style"

function iconForVolume(volume: number, muted: boolean) {
  if (muted) return phosphor.volumeMuted
  if (volume > 0.45) return phosphor.volumeHigh
  if (volume > 0) return phosphor.volumeMedium
  return phosphor.volumeLow
}

export default function Volume() {
  const volume = services.volume
  const flash = createFlash(volume((value) => `${value.volume}:${value.muted}`))

  return (
    <button
      {...pointerCursor}
      class={flash((active) =>
        barButtonClass(`module status-module ${active ? "module-flash" : ""}`),
      )}
      tooltipText="音量ミュート"
      onClicked={toggleVolumeMute}
    >
      <box spacing={6}>
        <label
          class="phosphor-icon"
          label={volume((value) => iconForVolume(value.volume, value.muted))}
        />
        <label label={volume((value) => `${Math.round(value.volume * 100)}%`)} />
      </box>
    </button>
  )
}
