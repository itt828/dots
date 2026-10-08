import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Theme

ColumnLayout {
    id: root
    required property var bluetoothService
    spacing: 12

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 52
        radius: 12
        color: Theme.surface
        border.color: Theme.outline
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            Text {
            font.family: Theme.fontFamily
            text: "Bluetooth"; font.bold: true; color: Theme.text }
            Text {
            font.family: Theme.fontFamily
                text: root.bluetoothService.available ? (root.bluetoothService.discovering ? "Scanning…" : "Ready") : "No adapter"
                color: Theme.textSecondary
                Layout.fillWidth: true
            }
            Button {
                text: root.bluetoothService.discovering ? "Stop" : "Scan"
                enabled: root.bluetoothService.enabled
                onClicked: root.bluetoothService.setDiscovering(!root.bluetoothService.discovering)
            }
            Switch {
                enabled: root.bluetoothService.available
                checked: root.bluetoothService.enabled
                onToggled: root.bluetoothService.setEnabled(checked)
            }
        }
    }

    ListView {
        Layout.fillWidth: true
        Layout.preferredHeight: 260
        clip: true
        spacing: 6
        model: root.bluetoothService.devices

        delegate: Rectangle {
            required property var modelData
            width: ListView.view.width
            height: 48
            radius: 10
            color: modelData.connected ? Theme.primaryContainer : Theme.surface
            border.color: modelData.connected ? Theme.primary : Theme.outline
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                Text {
            font.family: Theme.fontFamily
                    text: modelData.name || modelData.deviceName || modelData.address
                    color: Theme.text
                    font.bold: modelData.connected
                    Layout.fillWidth: true
                }
                Text {
            font.family: Theme.fontFamily
                    visible: modelData.batteryAvailable
                    text: Math.round(modelData.battery * 100) + "%"
                    color: Theme.textSecondary
                }
                Button {
                    text: modelData.connected ? "Disconnect" : (modelData.paired ? "Connect" : "Pair")
                    enabled: !modelData.pairing
                    onClicked: {
                        if (modelData.connected)
                            modelData.disconnect();
                        else if (modelData.paired)
                            modelData.connect();
                        else
                            modelData.pair();
                    }
                }
            }
        }

        Text {
            font.family: Theme.fontFamily
            anchors.centerIn: parent
            visible: root.bluetoothService.devices.length === 0
            text: root.bluetoothService.enabled ? "No Bluetooth devices found" : "Bluetooth is disabled"
            color: Theme.textSecondary
        }
    }
}
