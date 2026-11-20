import QtQuick
import qs.ui.theme
import qs.services
import qs.ui.widgets

Rectangle {
    id: root
    implicitWidth: display.implicitWidth + 16
    implicitHeight: 36
    width: implicitWidth
    height: implicitHeight
    radius: 8
    color: "transparent"
    scale: area.pressed ? 0.96 : 1
    Behavior on scale {
        QsNumberAnimation {
            duration: Theme.motionFast
        }
    }

    required property string outputName
    required property var networkService
    property bool showLabel: true

    HoverHandler {
        id: statusHover
    }

    QsHoverBackground {
        hovered: statusHover.hovered
    }

    QsIconLabel {
        id: display
        hoverBackground: false
        hovered: statusHover.hovered
        anchors.centerIn: parent
        maximumTextWidth: 92
        text: {
            if (!root.showLabel)
                return "";
            if (networkService.isConnected)
                return networkService.connectionName;
            if (!networkService.isWifiEnabled)
                return "Wi-Fi オフ";
            return "未接続";
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
                return Icons.wifiSlash;
            return Icons.wifiX;
        }

        color: networkService.isConnected ? Theme.ink : Theme.muted
    }
    MouseArea {
        id: area
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: ControlCenterService.openPage(5, root.outputName)
    }
}
