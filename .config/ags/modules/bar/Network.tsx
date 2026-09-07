import { services, type NetworkState } from "../../services"
import { pointerCursor } from "../common/cursor"
import { phosphor } from "../common/icons"
import { toggleWindow } from "../common/windows"
import { barButtonClass } from "./style"

function iconForNetwork(network: NetworkState) {
  if (!network.connected) return network.enabled ? phosphor.wifiX : phosphor.power
  if (!network.wifi) return phosphor.network
  if (network.signal > 80) return phosphor.wifiHigh
  if (network.signal > 50) return phosphor.wifiMedium
  if (network.signal > 20) return phosphor.wifiLow
  return phosphor.wifiNone
}

export default function Network() {
  return (
    <button
      {...pointerCursor}
      class={barButtonClass("module")}
      tooltipText="ネットワーク"
      onClicked={() => toggleWindow("dashboard")}
    >
      <box spacing={6}>
        <label class="phosphor-icon" label={services.network(iconForNetwork)} />
        <label label={services.network((network) => network.name)} />
      </box>
    </button>
  )
}
