import { services } from "../../services"

export default function WindowTitle() {
  return (
    <label class="window-title" label={services.windowTitle} maxWidthChars={42} ellipsize={3} />
  )
}
