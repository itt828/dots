import { services } from "../../services"
import { phosphor } from "../common/icons"

export default function Cpu() {
  return (
    <box class="module" spacing={6}>
      <label class="phosphor-icon" label={phosphor.cpu} />
      <label label={services.cpu} />
    </box>
  )
}
