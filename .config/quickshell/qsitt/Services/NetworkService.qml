import QtQuick
import Quickshell.Networking

QtObject {
    id: root

    readonly property var devices: Networking.devices ? Networking.devices.values : []

    readonly property var wifiAdapter: {
        for (var i = 0; i < devices.length; i++) {
            var dev = devices[i];
            if (dev && (dev.type === 1 || isWifiName(dev.name)))
                return dev;
        }
        return null;
    }

    readonly property var availableNetworks: wifiAdapter && wifiAdapter.networks
        ? wifiAdapter.networks.values : []

    readonly property var wiredDevice: {
        for (var i = 0; i < 20; i++) {
            var dev = devices[i];
            if (!dev)
                break;
            if (dev.connected && !isVirtual(dev.name) && !isWifiName(dev.name)) {
                if (dev.type === 1 || dev.name.match(/^(eth|en[posx]|usb)/))
                    return dev;
            }
        }
        return null;
    }

    readonly property var wifiDevice: {
        for (var i = 0; i < 20; i++) {
            var dev = devices[i];
            if (!dev)
                break;
            if (dev.connected && isWifiName(dev.name)) {
                return dev;
            }
        }
        return null;
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
        return "Disconnected";
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
