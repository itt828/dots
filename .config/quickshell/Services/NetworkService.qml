pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking

QtObject {
    id: root

    readonly property var activeWifiDevice: {
        var devices = Networking.devices;
        if (!devices || !devices.values) return null;
        
        for (var i = 0; i < 10; i++) {
            var dev = devices.values[i];
            if (!dev) break;
            if (dev.connected && (dev.type === 1 || dev.name.indexOf("wlan") === 0)) {
                return dev;
            }
        }
        return null;
    }

    readonly property var activeNetwork: {
        if (!activeWifiDevice || !activeWifiDevice.networks || !activeWifiDevice.networks.values) return null;
        
        var networks = activeWifiDevice.networks.values;
        for (var i = 0; i < 50; i++) {
            var net = networks[i];
            if (!net) break;
            if (net.connected) return net;
        }
        return null;
    }

    readonly property bool isConnected: Networking.connectivity >= 4 || activeWifiDevice !== null
    readonly property bool isWifiEnabled: Networking.wifiEnabled
    
    readonly property string connectionName: activeNetwork ? activeNetwork.name : "Disconnected"

    readonly property bool isWifi: activeWifiDevice !== null

    readonly property int signalStrength: {
        if (activeNetwork) {
            return Math.round(activeNetwork.signalStrength * 100);
        }
        return 100
    }
}
