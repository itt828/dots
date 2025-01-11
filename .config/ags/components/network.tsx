import { bind } from "astal";
import AstalNetwork from "gi://AstalNetwork";

export const Network = () => {
  const network = AstalNetwork.get_default()
  const wifi = bind(network, "wifi")
  return <box className="Network">
    {wifi.as(wifi => wifi && (
      <box spacing={8}>
        <icon
          tooltipText={bind(wifi, "ssid").as(String)}
          className="Wifi"
          icon={bind(wifi, "iconName")}
        />
        <label label={bind(wifi, "ssid").as(String)} />
      </box>
    ))}
  </box>

}
