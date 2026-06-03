import QtQuick
import "../../Assets"
import "../../Services"

Item {
    id: root
    implicitWidth: display.implicitWidth
    implicitHeight: display.implicitHeight
    width: implicitWidth
    height: implicitHeight

    required property var networkService

    IconLabel {
        id: display
        text: {
            if (networkService.isConnected) return networkService.connectionName
            if (!networkService.isWifiEnabled) return "Disabled"
            return "Disconnected"
        }

        icon: {
            if (networkService.isConnected) {
                if (!networkService.isWifi) return FontIcons.wifiHigh // Ethernet
                
                var signal = networkService.signalStrength
                if (signal > 80) return FontIcons.wifiHigh
                if (signal > 50) return FontIcons.wifiMedium
                if (signal > 20) return FontIcons.wifiLow
                return FontIcons.wifiNone
            }
            
            if (!networkService.isWifiEnabled) return FontIcons.power
            return FontIcons.wifiX
        }

        color: networkService.isConnected ? "black" : "#555555"
    }
}
