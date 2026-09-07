import { services, toggleMicrophoneMute } from "../../services"
import { pointerCursor } from "../common/cursor"
import { phosphor } from "../common/icons"
import { createFlash } from "./flash"
import { barButtonClass } from "./style"

export default function Microphone() {
  const microphone = services.microphone
  const flash = createFlash(microphone((value) => value.muted))

  return (
    <button
      {...pointerCursor}
      class={flash((active) =>
        barButtonClass(`module icon status-module ${active ? "module-flash" : ""}`),
      )}
      tooltipText="マイクミュート"
      onClicked={toggleMicrophoneMute}
    >
      <label
        class={microphone((value) => `phosphor-icon ${value.muted ? "text-danger" : "text-text"}`)}
        label={microphone((value) =>
          value.muted ? phosphor.microphoneSlash : phosphor.microphone,
        )}
      />
    </button>
  )
}
