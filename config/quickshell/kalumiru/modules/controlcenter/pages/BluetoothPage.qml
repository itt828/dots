pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import qs.ui.theme
import qs.ui.widgets

ColumnLayout {
    id: root

    required property var bluetoothService
    readonly property var connected: bluetoothService.devices.filter(device => device.connected)
    readonly property var paired: bluetoothService.devices.filter(device => device.paired && !device.connected)
    readonly property var nearby: bluetoothService.devices.filter(device => !device.paired && !device.connected && !device.blocked)
    readonly property string prompt: bluetoothService.prompt

    spacing: 10
    onVisibleChanged: {
        if (!visible)
            bluetoothService.cancelPairing();
    }

    component DeviceRow: QsDetailRow {
        id: entry

        required property var modelData
        readonly property bool busy: modelData.pairing || root.bluetoothService.pairingDevice === modelData
        title: modelData.name || modelData.deviceName || modelData.address
        subtitle: (modelData.connected ? "接続済み" : modelData.paired ? "登録済み" : "ペアリング可能") + (modelData.batteryAvailable ? " · バッテリー " + Math.round(modelData.battery * 100) + "%" : "")
        icon: Icons.bluetooth

        QsButton {
            text: entry.busy ? "処理中…" : entry.modelData.connected ? "切断" : entry.modelData.paired ? "接続" : "ペアリング"
            implicitHeight: 30
            horizontalPadding: 8
            enabled: !entry.busy && !root.bluetoothService.pairing
            onClicked: {
                const device = entry.modelData;
                if (device.connected)
                    device.disconnect();
                else if (device.paired)
                    device.connect();
                else
                    root.bluetoothService.pair(device);
            }
        }
    }

    QsPanelCard {
        QsDetailRow {
            title: "Bluetooth"
            icon: Icons.bluetooth
            subtitle: !root.bluetoothService.available ? "アダプターが見つかりません" : root.bluetoothService.enabled ? "オン" : "オフ"

            QsSwitch {
                Accessible.name: "Bluetooth"
                enabled: root.bluetoothService.available
                checked: root.bluetoothService.enabled
                onToggled: checked => root.bluetoothService.setEnabled(checked)
            }
        }
    }

    QsSectionLabel {
        visible: root.bluetoothService.enabled
        text: "接続済み"
    }
    QsPanelCard {
        visible: root.bluetoothService.enabled
        highlighted: root.connected.length > 0

        QsSectionLabel {
            visible: root.connected.length === 0
            text: "接続中のデバイスはありません"
        }
        Repeater {
            model: root.connected
            DeviceRow {}
        }
    }

    QsSectionLabel {
        visible: root.bluetoothService.enabled && root.paired.length > 0
        text: "登録済み"
    }
    QsPanelCard {
        visible: root.bluetoothService.enabled && root.paired.length > 0

        Repeater {
            model: root.paired
            DeviceRow {}
        }
    }

    RowLayout {
        visible: root.bluetoothService.enabled
        Layout.fillWidth: true

        QsSectionLabel {
            Layout.fillWidth: true
            text: "近くのデバイス"
        }
        QsButton {
            text: root.bluetoothService.discovering ? "スキャンを停止" : "スキャン"
            implicitHeight: 30
            horizontalPadding: 8
            onClicked: root.bluetoothService.setDiscovering(!root.bluetoothService.discovering)
        }
    }
    QsPanelCard {
        visible: root.bluetoothService.enabled

        QsSectionLabel {
            visible: root.nearby.length === 0
            text: root.bluetoothService.discovering ? "近くのデバイスを検索中…" : "近くに未登録の機器はありません"
        }
        Repeater {
            model: root.nearby
            DeviceRow {}
        }

        ColumnLayout {
            id: request
            visible: root.bluetoothService.pairing
            Layout.fillWidth: true
            spacing: 8

            QsDetailRow {
                title: root.bluetoothService.pairingDevice?.name ?? "Bluetooth"
                subtitle: {
                    switch (root.prompt) {
                    case "confirm":
                        return "接続先の番号と一致することを確認してください";
                    case "display":
                        return "接続先にこの番号を入力してください";
                    case "pin":
                        return "接続先の PIN を入力してください";
                    case "passkey":
                        return "接続先のパスキーを入力してください";
                    case "authorize":
                        return "この機器のペアリングを許可しますか";
                    default:
                        return "ペアリング中…";
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    visible: root.bluetoothService.pairingCode !== ""
                    text: root.bluetoothService.pairingCode
                    font.family: "monospace"
                    font.pixelSize: Theme.fontSizeTitle
                    color: Theme.mustard800
                }
                Controls.TextField {
                    id: passkey
                    visible: root.prompt === "pin" || root.prompt === "passkey"
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    placeholderText: root.prompt === "pin" ? "PIN" : "パスキー"
                    Accessible.name: placeholderText
                    maximumLength: root.prompt === "pin" ? 16 : 6
                    inputMethodHints: root.prompt === "pin" ? Qt.ImhSensitiveData : Qt.ImhDigitsOnly | Qt.ImhSensitiveData
                    onVisibleChanged: {
                        if (visible)
                            forceActiveFocus();
                        else
                            clear();
                    }
                    onAccepted: if (entryAccept.enabled)
                        root.bluetoothService.answer(text)
                }
                Item {
                    visible: !passkey.visible
                    Layout.fillWidth: true
                }
                QsButton {
                    text: "キャンセル"
                    implicitHeight: 30
                    horizontalPadding: 7
                    onClicked: root.bluetoothService.cancelPairing()
                }
                QsButton {
                    id: entryAccept
                    visible: ["pin", "passkey", "confirm", "authorize"].includes(root.prompt)
                    enabled: !passkey.visible || (root.prompt === "pin" ? passkey.length > 0 : /^[0-9]{1,6}$/.test(passkey.text))
                    text: passkey.visible ? "送信" : "許可"
                    variant: QsButton.Primary
                    implicitHeight: 30
                    horizontalPadding: 8
                    onClicked: root.bluetoothService.answer(passkey.visible ? passkey.text : true)
                }
            }
        }
    }

    QsSectionLabel {
        visible: !root.bluetoothService.pairing && root.bluetoothService.pairingStatus !== ""
        text: root.bluetoothService.pairingStatus
    }
}
