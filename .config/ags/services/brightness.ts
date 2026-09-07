import { subprocess } from "ags/process"
import { createState } from "gnim"

import { output, run } from "./command"

export const [brightness, setBrightnessState] = createState(0)

export function setBrightness(value: number) {
  const next = Math.max(0, Math.min(1, value))
  setBrightnessState(next)
  run(["brightnessctl", "set", `${Math.round(next * 100)}%`])
}

async function refreshBrightness() {
  const parts = (await output(["brightnessctl", "-m", "i"])).split(",")
  const current = Number(parts[2])
  const maximum = Number(parts[4])
  setBrightnessState(maximum > 0 ? current / maximum : 0)
}

void refreshBrightness()
subprocess({
  cmd: ["udevadm", "monitor", "-s", "backlight"],
  out(line) {
    if (line.includes("change")) void refreshBrightness()
  },
  err() {},
})
