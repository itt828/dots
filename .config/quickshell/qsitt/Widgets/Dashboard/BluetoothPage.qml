import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    required property var bluetoothService
    spacing: 12

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 52
        radius: 8
        color: "#ffffff"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            Text { text: "Bluetooth"; font.bold: true; color: "#37474f" }
            Text {
                text: root.bluetoothService.available ? (root.bluetoothService.discovering ? "Scanning…" : "Ready") : "No adapter"
                color: "#607d8b"
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
            radius: 8
            color: modelData.connected ? "#e3f2fd" : "#ffffff"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                Text {
                    text: modelData.name || modelData.deviceName || modelData.address
                    color: "#37474f"
                    font.bold: modelData.connected
                    Layout.fillWidth: true
                }
                Text {
                    visible: modelData.batteryAvailable
                    text: Math.round(modelData.battery * 100) + "%"
                    color: "#607d8b"
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
            anchors.centerIn: parent
            visible: root.bluetoothService.devices.length === 0
            text: root.bluetoothService.enabled ? "No Bluetooth devices found" : "Bluetooth is disabled"
            color: "#607d8b"
        }
    }
}
