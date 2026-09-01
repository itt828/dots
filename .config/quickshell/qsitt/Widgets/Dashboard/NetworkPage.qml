import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    required property var networkService
    spacing: 12

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 52
        radius: 8
        color: "#ffffff"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            Text { text: "Wi-Fi"; font.bold: true; color: "#37474f" }
            Text { text: root.networkService.connectionName; color: "#607d8b"; Layout.fillWidth: true }
            Switch {
                checked: root.networkService.isWifiEnabled
                onToggled: root.networkService.setWifiEnabled(checked)
            }
        }
    }

    ListView {
        Layout.fillWidth: true
        Layout.preferredHeight: 260
        clip: true
        spacing: 6
        model: root.networkService.availableNetworks

        delegate: Rectangle {
            required property var modelData
            width: ListView.view.width
            height: 48
            radius: 8
            color: modelData.connected ? "#e3f2fd" : "#ffffff"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                Text { text: modelData.name; color: "#37474f"; font.bold: modelData.connected; Layout.fillWidth: true }
                Text { text: Math.round(modelData.signalStrength * 100) + "%"; color: "#607d8b" }
                Button {
                    text: modelData.connected ? "Disconnect" : "Connect"
                    enabled: !modelData.stateChanging
                    onClicked: modelData.connected ? modelData.disconnect() : modelData.connect()
                }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: root.networkService.availableNetworks.length === 0
            text: root.networkService.isWifiEnabled ? "No Wi-Fi networks found" : "Wi-Fi is disabled"
            color: "#607d8b"
        }
    }
}
