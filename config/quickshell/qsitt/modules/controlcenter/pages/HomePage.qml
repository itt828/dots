pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import Quickshell.Services.UPower
import qs.modules.controlcenter.widgets
import qs.services
import qs.ui.theme
import qs.ui.widgets

Flickable {
    id: root

    required property bool compact
    required property string outputName
    signal openPage(int page)

    readonly property var battery: UPower.displayDevice
    readonly property int connectedBluetoothCount: BluetoothService.devices.filter(device => device.connected).length

    clip: true
    contentWidth: width
    contentHeight: content.implicitHeight
    implicitHeight: contentHeight
    boundsBehavior: Flickable.StopAtBounds

    Controls.ScrollBar.vertical: Controls.ScrollBar {
        policy: Controls.ScrollBar.AsNeeded
    }

    function openNotifications(): void {
        ControlCenterService.visible = false;
        NotificationService.openFor(outputName);
    }

    component QuickTile: Rectangle {
        id: tile

        required property string label
        required property string detail
        required property string icon
        property bool checked: false
        signal detailsRequested

        Layout.fillWidth: true
        Layout.minimumWidth: 0
        implicitWidth: 180
        implicitHeight: 62
        radius: 13
        color: checked ? Theme.mustard200 : Theme.bgSecondary
        border.color: activeFocus ? Theme.focus : Theme.borderPrimary
        border.width: activeFocus ? 2 : 1
        activeFocusOnTab: true
        Accessible.role: Accessible.Button
        Accessible.name: label
        Accessible.description: detail
        Accessible.onPressAction: detailsRequested()
        Keys.onSpacePressed: detailsRequested()
        Keys.onReturnPressed: detailsRequested()

        QsHoverBackground {
            anchors.margins: tile.border.width
            hovered: area.containsMouse
            radius: tile.radius - 1
            color: Theme.withAlpha(Theme.ink, 0.06)
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 9
            spacing: 9

            QsDetailRow {
                Layout.fillWidth: true
                icon: tile.icon
                title: tile.label
                subtitle: tile.detail
            }
            QsIcon {
                icon: Icons.caretRight
                size: 18
                color: Theme.muted
            }
        }

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: tile.detailsRequested()
        }
    }

    component LevelControl: RowLayout {
        id: level
        required property string label
        required property real value
        required property string icon
        property bool canToggle: false
        signal moved(real value)
        signal toggled

        Layout.fillWidth: true
        spacing: 8

        QsIcon {
            visible: !level.canToggle
            icon: level.icon
            size: 23
            color: Theme.mustard800
        }
        QsButton {
            visible: level.canToggle
            icon: level.icon
            variant: QsButton.Ghost
            implicitWidth: 29
            implicitHeight: 32
            toolTip: "ミュートを切り替え"
            onClicked: level.toggled()
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            QsSectionLabel {
                text: level.label
            }
            QsSlider {
                Layout.fillWidth: true
                implicitHeight: 18
                Accessible.name: level.label
                value: level.value
                onMoved: value => level.moved(value)
            }
        }
        Text {
            Layout.preferredWidth: 39
            horizontalAlignment: Text.AlignRight
            text: level.enabled ? Math.round(level.value * 100) + "%" : "—"
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    ColumnLayout {
        id: content
        width: root.width
        spacing: 10

        GridLayout {
            Layout.fillWidth: true
            columns: root.width >= 330 ? 2 : 1
            columnSpacing: 8
            rowSpacing: 8

            QuickTile {
                label: "Wi-Fi"
                icon: Icons.wifiHigh
                detail: !NetworkService.isWifiEnabled ? "オフ" : (NetworkService.activeNetwork?.name ?? "未接続")
                checked: NetworkService.isWifiEnabled
                onDetailsRequested: root.openPage(5)
            }
            QuickTile {
                label: "Bluetooth"
                icon: Icons.bluetooth
                detail: !BluetoothService.available ? "機器なし" : BluetoothService.enabled ? (root.connectedBluetoothCount > 0 ? root.connectedBluetoothCount + " 台接続済み" : "オン") : "オフ"
                checked: BluetoothService.enabled
                onDetailsRequested: root.openPage(6)
            }
            QuickTile {
                label: "おやすみモード"
                icon: Icons.moon
                detail: NotificationService.dnd ? "オン" : NotificationService.history.count + " 件の通知"
                checked: NotificationService.dnd
                onDetailsRequested: root.openNotifications()
            }
            QuickTile {
                label: "夜間モード"
                icon: Icons.sun
                detail: AppearanceService.canSetNight ? (checked ? "オン" : "オフ") : "wlsunset が必要"
                checked: AppearanceService.nightEnabled
                onDetailsRequested: ControlCenterService.openPage(7, root.outputName, "display")
            }
        }

        QsPanelCard {
            LevelControl {
                label: VolumeService.muted ? "音量 · ミュート" : "音量"
                icon: VolumeService.muted ? Icons.volumeMuted : Icons.volumeHigh
                value: VolumeService.volume
                enabled: VolumeService.sink !== null
                canToggle: true
                onToggled: VolumeService.toggleMute()
                onMoved: value => VolumeService.setVolume(value)
            }
            LevelControl {
                label: "明るさ"
                icon: Icons.sun
                value: BrightnessService.displayBrightness
                enabled: BrightnessService.initialized
                onMoved: value => BrightnessService.setBrightness(value)
            }
        }

        Loader {
            Layout.fillWidth: true
            active: SettingsService.showMediaInfo && MediaService.players.length > 0
            visible: active
            sourceComponent: MediaControl {
                compact: true
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: root.width < 400 ? 2 : 4
            columnSpacing: 6
            rowSpacing: 6

            QsButton {
                Layout.fillWidth: true
                text: "スクショ"
                labelSize: 11
                horizontalPadding: 6
                onClicked: ControlCenterService.screenshot()
            }
            QsButton {
                Layout.fillWidth: true
                text: RecorderService.recording ? "録画を停止" : "画面録画"
                labelSize: 11
                horizontalPadding: 6
                enabled: RecorderService.recording || !RecorderService.busy
                onClicked: RecorderService.toggle(root.outputName)
            }
            QsButton {
                Layout.fillWidth: true
                text: "コピー履歴"
                labelSize: 11
                horizontalPadding: 6
                onClicked: {
                    ControlCenterService.visible = false;
                    SearchService.openOnOutput(root.outputName, "clipboard");
                }
            }
            QsButton {
                Layout.fillWidth: true
                text: "集中タイマー"
                labelSize: 11
                horizontalPadding: 6
                onClicked: root.openPage(3)
            }
        }

        QsMarqueeText {
            Layout.fillWidth: true
            visible: RecorderService.status !== ""
            text: RecorderService.status
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.muted
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Theme.borderPrimary
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            QsIconLabel {
                visible: root.battery?.isPresent ?? false
                icon: Icons.batteryFull
                text: Math.round((root.battery?.percentage ?? 0) * 100) + "%"
            }
            QsSectionLabel {
                visible: (root.battery?.isPresent ?? false) && UPower.onBattery && (root.battery?.timeToEmpty ?? 0) >= 60
                text: {
                    const minutes = Math.floor((root.battery?.timeToEmpty ?? 0) / 60);
                    return minutes >= 60 ? "残り約 " + Math.floor(minutes / 60) + " 時間 " + minutes % 60 + " 分" : "残り約 " + minutes + " 分";
                }
            }
            Item {
                Layout.fillWidth: true
            }

            QsButton {
                icon: Icons.cpu
                toolTip: "システムモニター"
                variant: QsButton.Ghost
                onClicked: root.openPage(2)
            }
            QsButton {
                icon: Icons.lock
                toolTip: "ロック"
                variant: QsButton.Ghost
                onClicked: {
                    ControlCenterService.visible = false;
                    PowerService.lock();
                }
            }
            QsButton {
                id: powerButton
                icon: Icons.power
                toolTip: "電源"
                variant: QsButton.Ghost
                onClicked: {
                    PowerService.toggleAt(root.outputName, powerButton);
                    ControlCenterService.visible = false;
                }
            }
        }
    }
}
