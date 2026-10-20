import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common.theme

ColumnLayout {
    id: root
    required property var networkService
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
            text: "Wi-Fi"; font.bold: true; color: Theme.text }
            Text {
            font.family: Theme.fontFamily
            text: root.networkService.connectionName; color: Theme.textSecondary; Layout.fillWidth: true }
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
            radius: 10
            color: modelData.connected ? Theme.primaryContainer : Theme.surface
            border.color: modelData.connected ? Theme.primary : Theme.outline
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                Text {
            font.family: Theme.fontFamily
            text: modelData.name; color: Theme.text; font.bold: modelData.connected; Layout.fillWidth: true }
                Text {
            font.family: Theme.fontFamily
            text: Math.round(modelData.signalStrength * 100) + "%"; color: Theme.textSecondary }
                Button {
                    text: modelData.connected ? "Disconnect" : "Connect"
                    enabled: !modelData.stateChanging
                    onClicked: modelData.connected ? modelData.disconnect() : modelData.connect()
                }
            }
        }

        Text {
            font.family: Theme.fontFamily
            anchors.centerIn: parent
            visible: root.networkService.availableNetworks.length === 0
            text: root.networkService.isWifiEnabled ? "No Wi-Fi networks found" : "Wi-Fi is disabled"
            color: Theme.textSecondary
        }
    }
}
