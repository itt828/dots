import { services, type BatteryState } from "../../services"
import { phosphor } from "../common/icons"

function iconForBattery(battery: BatteryState) {
  if (battery.charging) return phosphor.batteryCharging
  if (battery.percentage > 90) return phosphor.batteryFull
  if (battery.percentage > 70) return phosphor.batteryHigh
  if (battery.percentage > 30) return phosphor.batteryMedium
  return phosphor.batteryLow
}

export default function Battery() {
  return (
    <box
      class={services.battery((battery) =>
        battery.percentage < 20 && !battery.charging ? "battery-low module" : "module",
      )}
      visible={services.battery((battery) => battery.present)}
      spacing={6}
    >
      <label class="phosphor-icon" label={services.battery(iconForBattery)} />
      <label label={services.battery((battery) => `${battery.percentage}%`)} />
    </box>
  )
}
