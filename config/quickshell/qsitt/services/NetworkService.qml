pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Networking
import Quickshell.Io

QtObject {
    id: root

    readonly property var devices: Networking.devices ? Networking.devices.values : []

    readonly property var wifiAdapter: devices.find(device => device.type === DeviceType.Wifi || isWifiName(device.name)) ?? null
    readonly property var availableNetworks: wifiAdapter?.networks?.values ?? []
    readonly property var ethernet: devices.find(device => device.type === DeviceType.Wired && !isVirtual(device.name)) ?? null
    readonly property var wiredDevice: devices.find(device => device.connected && device.type === DeviceType.Wired && !isVirtual(device.name)) ?? null
    readonly property var wifiDevice: devices.find(device => device.connected && (device.type === DeviceType.Wifi || isWifiName(device.name))) ?? null
    readonly property bool scanning: scan.running
    readonly property bool vpnBusy: vpnRefresh.running || vpnChange.running
    property var vpnProfiles: []
    property string lastScanError: ""
    property string vpnError: ""

    function rescan(): void {
        if (!wifiAdapter || scanning)
            return;
        lastScanError = "";
        scan.running = true;
    }

    function refreshVpn(): void {
        if (!vpnRefresh.running && !vpnChange.running)
            vpnRefresh.running = true;
    }

    function toggleVpn(profile: var): void {
        if (!vpnBusy && /^[0-9a-f-]{36}$/i.test(profile.uuid)) {
            vpnError = "";
            vpnChange.exec(["nmcli", "--wait", "20", "connection", profile.active ? "down" : "up", "uuid", profile.uuid]);
        }
    }

    readonly property Process scan: Process {
        command: ["nmcli", "--wait", "10", "device", "wifi", "rescan", "ifname", root.wifiAdapter?.name ?? ""]
        onExited: code => root.lastScanError = code === 0 ? "" : "Wi-Fi を再スキャンできませんでした"
    }

    readonly property Process vpnRefresh: Process {
        command: ["nmcli", "--terse", "--escape", "no", "--fields", "UUID,TYPE,ACTIVE,NAME", "connection", "show"]
        environment: ({
                LC_ALL: "C"
            })
        stdout: StdioCollector {
            onStreamFinished: {
                const profiles = [];
                for (const line of text.split("\n")) {
                    const match = /^([0-9a-f-]{36}):(vpn|wireguard):(yes|no):(.*)$/i.exec(line);
                    if (match)
                        profiles.push({
                            uuid: match[1],
                            active: match[3] === "yes",
                            name: match[4]
                        });
                }
                root.vpnProfiles = profiles;
            }
        }
    }

    readonly property Process vpnChange: Process {
        onExited: code => {
            root.vpnError = code === 0 ? "" : "VPN の接続状態を切り替えられませんでした";
            Qt.callLater(root.refreshVpn);
        }
    }

    function isVirtual(name) {
        return name.match(/^(lo|docker|veth|br-|virbr|wg-|tailscale|tun|tap)/);
    }

    function isWifiName(name) {
        return name.match(/^(wlan|wl[pos])/);
    }

    readonly property var activeDevice: wiredDevice || wifiDevice

    readonly property var activeNetwork: {
        if (!wifiDevice || !wifiDevice.networks || !wifiDevice.networks.values)
            return null;

        var networks = wifiDevice.networks.values;
        for (var i = 0; i < 50; i++) {
            var net = networks[i];
            if (!net)
                break;
            if (net.connected)
                return net;
        }
        return null;
    }

    readonly property bool isConnected: Networking.connectivity >= 4 || activeDevice !== null
    readonly property bool isWifiEnabled: Networking.wifiEnabled

    function setWifiEnabled(enabled) {
        Networking.wifiEnabled = enabled;
    }

    readonly property string connectionName: {
        if (isWired)
            return wiredDevice.name;
        if (activeNetwork)
            return activeNetwork.name;
        if (wifiDevice)
            return wifiDevice.name;
        return "未接続";
    }

    readonly property bool isWifi: wifiDevice !== null
    readonly property bool isWired: wiredDevice !== null

    readonly property int signalStrength: {
        if (isWifi && activeNetwork) {
            return Math.round(activeNetwork.signalStrength * 100);
        }
        return 100;
    }
}
