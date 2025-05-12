import { bind } from "astal";
import AstalNetwork from "gi://AstalNetwork";


export const Network = () => {
    const network = AstalNetwork.get_default()
    const wifi = bind(network, "wifi").get()


    return <box cssClasses={["Network"]} spacing={8}>
        <image
            tooltipText={bind(wifi, "ssid").as(String)}
            cssName="Wifi"
            iconName={bind(wifi, "iconName")}
        />
        <label label={bind(wifi, "ssid").as(String)} />
    </box >

}


