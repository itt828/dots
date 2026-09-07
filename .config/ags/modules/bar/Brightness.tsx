import { services } from "../../services"
import { phosphor } from "../common/icons"
import { createFlash } from "./flash"

export default function Brightness() {
  const brightness = services.brightness
  const flash = createFlash(brightness)

  return (
    <box
      class={flash((active) => `module status-module ${active ? "module-flash" : ""}`)}
      spacing={6}
    >
      <label class="phosphor-icon" label={phosphor.sunDim} />
      <label label={brightness((value) => `${Math.round(value * 100)}%`)} />
    </box>
  )
}
