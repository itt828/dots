import { services } from "../../services"
import { phosphor } from "../common/icons"

export default function Memory() {
  return (
    <box class="module" spacing={6}>
      <label class="phosphor-icon" label={phosphor.ram} />
      <label label={services.memory} />
    </box>
  )
}
