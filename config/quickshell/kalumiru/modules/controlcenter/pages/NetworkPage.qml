pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import Quickshell.Networking
import qs.ui.widgets
import qs.ui.theme

ColumnLayout {
    id: root

    required property var networkService
    property var passwordNetwork: null
    property var attemptNetwork: null
    property string connectionError: ""
    readonly property var connectedNetwork: networkService.activeNetwork
    readonly property var otherNetworks: networkService.availableNetworks.filter(network => !network.connected && network.name).sort((a, b) => (Number(b.known) - Number(a.known)) || (b.signalStrength - a.signalStrength))

    spacing: 10

    function label(network: var): string {
        let protection = "保護あり";
        if (network.security === WifiSecurityType.Open)
            protection = "オープン";
        else if (network.security === WifiSecurityType.Owe)
            protection = "暗号化";
        else if (network.security === WifiSecurityType.Sae)
            protection = "WPA3";
        else if (network.security === WifiSecurityType.Wpa2Psk)
            protection = "WPA2";
        return (network.known && !network.connected ? "保存済み · " : "") + protection + " · " + Math.round(network.signalStrength * 100) + "%";
    }

    function requestConnect(network: var): void {
        connectionError = "";
        attemptNetwork = network;
        if (!network.known && supportsPassword(network)) {
            passwordNetwork = network;
            return;
        }
        passwordNetwork = null;
        network.connect();
    }

    function supportsPassword(network: var): bool {
        return [WifiSecurityType.Wpa2Psk, WifiSecurityType.WpaPsk, WifiSecurityType.Sae, WifiSecurityType.StaticWep].includes(network.security);
    }

    onVisibleChanged: {
        if (visible) {
            networkService.refreshVpn();
        } else {
            passwordNetwork = null;
            attemptNetwork = null;
            connectionError = "";
        }
    }

    Connections {
        target: root.attemptNetwork
        function onConnectionFailed(reason): void {
            root.connectionError = reason === ConnectionFailReason.NoSecrets ? "認証情報を確認してください" : "Wi-Fi に接続できませんでした";
            if (root.attemptNetwork && root.supportsPassword(root.attemptNetwork))
                root.passwordNetwork = root.attemptNetwork;
        }
        function onConnectedChanged(): void {
            if (root.attemptNetwork?.connected) {
                root.passwordNetwork = null;
                root.connectionError = "";
            }
        }
    }

    QsPanelCard {
        QsDetailRow {
            title: "Wi-Fi"
            icon: Icons.wifiHigh
            subtitle: !root.networkService.wifiAdapter ? "アダプターが見つかりません" : root.networkService.isWifiEnabled ? "オン" : "オフ"

            QsSwitch {
                Accessible.name: "Wi-Fi"
                enabled: !!root.networkService.wifiAdapter
                checked: root.networkService.isWifiEnabled
                onToggled: checked => {
                    root.passwordNetwork = null;
                    root.attemptNetwork = null;
                    root.connectionError = "";
                    root.networkService.setWifiEnabled(checked);
                }
            }
        }
    }

    QsSectionLabel {
        visible: root.networkService.isWifiEnabled
        text: "接続中"
    }

    QsPanelCard {
        visible: root.networkService.isWifiEnabled
        highlighted: !!root.connectedNetwork

        QsDetailRow {
            title: root.connectedNetwork?.name ?? "未接続"
            icon: Icons.wifiHigh
            subtitle: root.connectedNetwork ? root.label(root.connectedNetwork) : ""

            QsButton {
                visible: !!root.connectedNetwork
                text: "切断"
                implicitHeight: 30
                horizontalPadding: 9
                enabled: !(root.connectedNetwork?.stateChanging ?? false)
                onClicked: root.connectedNetwork?.disconnect()
            }
        }
    }

    RowLayout {
        visible: root.networkService.isWifiEnabled && !!root.networkService.wifiAdapter
        Layout.fillWidth: true

        QsSectionLabel {
            Layout.fillWidth: true
            text: "利用可能なネットワーク"
        }
        QsButton {
            text: root.networkService.scanning ? "検索中…" : "再スキャン"
            implicitHeight: 30
            horizontalPadding: 8
            enabled: !root.networkService.scanning
            onClicked: root.networkService.rescan()
        }
    }

    QsPanelCard {
        visible: root.networkService.isWifiEnabled && !!root.networkService.wifiAdapter

        QsSectionLabel {
            visible: root.otherNetworks.length === 0
            text: "利用可能なネットワークが見つかりません"
        }

        Repeater {
            model: root.otherNetworks

            ColumnLayout {
                id: entry
                required property var modelData

                Layout.fillWidth: true
                spacing: 6

                QsDetailRow {
                    title: entry.modelData.name
                    icon: entry.modelData.security === WifiSecurityType.Open || entry.modelData.security === WifiSecurityType.Owe ? Icons.wifiHigh : Icons.lock
                    subtitle: root.label(entry.modelData)

                    QsButton {
                        text: entry.modelData.stateChanging ? "接続中…" : "接続"
                        implicitHeight: 30
                        horizontalPadding: 9
                        enabled: !entry.modelData.stateChanging
                        highlighted: root.passwordNetwork === entry.modelData
                        onClicked: root.requestConnect(entry.modelData)
                    }
                }

                RowLayout {
                    id: prompt
                    visible: root.passwordNetwork === entry.modelData
                    Layout.fillWidth: true
                    onVisibleChanged: {
                        if (visible)
                            input.forceActiveFocus();
                        else
                            input.clear();
                    }

                    function connectWithPassword(): void {
                        if (!input.text)
                            return;
                        root.connectionError = "";
                        entry.modelData.connectWithPsk(input.text);
                        input.clear();
                    }

                    Controls.TextField {
                        id: input
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        implicitHeight: 34
                        placeholderText: "Wi-Fi パスワード"
                        Accessible.name: placeholderText
                        echoMode: TextInput.Password
                        inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText | Qt.ImhHiddenText
                        font.family: Theme.fontFamily
                        onAccepted: prompt.connectWithPassword()
                        Keys.onEscapePressed: root.passwordNetwork = null
                    }

                    QsButton {
                        icon: Icons.x
                        toolTip: "パスワード入力をキャンセル"
                        implicitHeight: 30
                        variant: QsButton.Ghost
                        onClicked: root.passwordNetwork = null
                    }
                    QsButton {
                        text: "接続"
                        variant: QsButton.Primary
                        implicitHeight: 30
                        horizontalPadding: 8
                        enabled: input.length > 0 && !entry.modelData.stateChanging
                        onClicked: prompt.connectWithPassword()
                    }
                }
            }
        }
    }

    QsSectionLabel {
        readonly property string message: root.connectionError || root.networkService.lastScanError
        text: message
        color: Theme.error
        visible: message !== ""
    }

    QsSectionLabel {
        text: "その他の接続"
    }

    QsPanelCard {
        QsDetailRow {
            title: "有線接続"
            icon: Icons.network
            subtitle: root.networkService.wiredDevice?.name ?? (root.networkService.ethernet?.hasLink ? "接続待ち" : "ケーブル未接続")
        }

        QsDetailRow {
            visible: root.networkService.vpnProfiles.length === 0
            title: "VPN"
            subtitle: "登録済みの VPN はありません"
        }

        Repeater {
            model: root.networkService.vpnProfiles

            QsDetailRow {
                id: vpn
                required property var modelData
                title: modelData.name
                subtitle: modelData.active ? "VPN · 接続済み" : "VPN · 未接続"

                QsSwitch {
                    Accessible.name: "VPN " + vpn.modelData.name
                    checked: vpn.modelData.active
                    enabled: !root.networkService.vpnBusy
                    onToggled: root.networkService.toggleVpn(vpn.modelData)
                }
            }
        }

        QsSectionLabel {
            visible: root.networkService.vpnError !== ""
            text: root.networkService.vpnError
            color: Theme.error
        }
    }

    Timer {
        interval: 5000
        running: root.visible
        repeat: true
        onTriggered: root.networkService.refreshVpn()
    }
}
