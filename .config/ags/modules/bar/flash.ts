import { timeout } from "ags/time"
import { createEffect, createState, onCleanup, type Accessor } from "gnim"

export function createFlash(trigger: Accessor<unknown>) {
  const [flashing, setFlashing] = createState(false)
  let initialized = false
  let previous: unknown
  let timer: ReturnType<typeof timeout> | undefined

  createEffect(() => {
    const value = trigger()
    if (!initialized) {
      initialized = true
      previous = value
      return
    }
    if (Object.is(previous, value)) return
    previous = value

    timer?.cancel()
    setFlashing(true)
    timer = timeout(600, () => setFlashing(false))
  })

  onCleanup(() => timer?.cancel())
  return flashing
}
