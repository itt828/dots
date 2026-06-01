import QtQuick
import "../../Assets"
import "../../Services"

Item {
    id: root
    implicitWidth: display.implicitWidth
    implicitHeight: display.implicitHeight
    width: implicitWidth
    height: implicitHeight

    IconLabel {
        id: display
        text: {
            if (NetworkService.isConnected) return NetworkService.connectionName
            if (!NetworkService.isWifiEnabled) return "Disabled"
            return "Disconnected"
        }

        icon: {
            if (NetworkService.isConnected) {
                if (!NetworkService.isWifi) return FontIcons.wifiHigh // Ethernet
                
                var signal = NetworkService.signalStrength
                if (signal > 80) return FontIcons.wifiHigh
                if (signal > 50) return FontIcons.wifiMedium
                if (signal > 20) return FontIcons.wifiLow
                return FontIcons.wifiNone
            }
            
            if (!NetworkService.isWifiEnabled) return FontIcons.power
            return FontIcons.wifiX
        }

        color: NetworkService.isConnected ? "black" : "#555555"
    }
}
