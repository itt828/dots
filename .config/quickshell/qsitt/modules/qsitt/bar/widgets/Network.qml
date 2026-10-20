import QtQuick
import qs.modules.common.theme
import qs.services
import qs.modules.common.widgets

Item {
    id: root
    implicitWidth: display.implicitWidth
    implicitHeight: display.implicitHeight
    width: implicitWidth
    height: implicitHeight

    required property var networkService

    QsIconLabel {
        id: display
        text: {
            if (networkService.isConnected)
                return networkService.connectionName;
            if (!networkService.isWifiEnabled)
                return "Disabled";
            return "Disconnected";
        }

        icon: {
            if (networkService.isConnected) {
                if (networkService.isWired)
                    return Icons.network;

                if (networkService.isWifi) {
                    var signal = networkService.signalStrength;
                    if (signal > 80)
                        return Icons.wifiHigh;
                    if (signal > 50)
                        return Icons.wifiMedium;
                    if (signal > 20)
                        return Icons.wifiLow;
                    return Icons.wifiNone;
                }

                return Icons.network;
            }

            if (!networkService.isWifiEnabled)
                return Icons.power;
            return Icons.wifiX;
        }

        color: networkService.isConnected ? Theme.text : Theme.textSecondary
    }
}
