pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.ui.theme
import qs.services
import qs.ui.widgets
import qs.modules.controlcenter.pages
import qs.modules.controlcenter.widgets
import qs.modules.notifications

Scope {
    id: root

    readonly property var controlCenterService: ControlCenterService
    readonly property var volumeService: VolumeService
    readonly property var networkService: NetworkService
    readonly property var bluetoothService: BluetoothService
    readonly property var notificationService: NotificationService

    Variants {
        model: Quickshell.screens.filter(screen => SettingsService.targetScreens.length === 0 || SettingsService.targetScreens.includes(screen.name))

        PanelWindow {
            id: controlCenterWindow

            required property var modelData
            property int currentPage: 0
            Connections {
                target: ControlCenterService
                function onRequestedPageChanged(): void {
                    controlCenterWindow.currentPage = ControlCenterService.requestedPage;
                }
                function onVisibleChanged(): void {
                    if (ControlCenterService.visible)
                        controlCenterWindow.currentPage = ControlCenterService.requestedPage;
                }
            }

            screen: modelData
            visible: true
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: ControlCenterService.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            mask: Region {
                item: ControlCenterService.visible ? dismissLayer : null
            }

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            Rectangle {
                id: dismissLayer
                anchors.fill: parent
                visible: ControlCenterService.visible
                color: Theme.withAlpha("#101820", 0.18)

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.controlCenterService.visible = false
                }
            }

            Rectangle {
                id: controlCenterContent

                visible: ControlCenterService.visible

                anchors {
                    top: parent.top
                    topMargin: Theme.barHeight + Theme.barOuterMargin + 12
                    right: parent.right
                    rightMargin: 16
                }

                width: Math.min(660, parent.width - 32)
                height: Math.min(740, parent.height - anchors.topMargin - 20)
                color: Theme.surface
                radius: Theme.radiusLarge
                border.color: Theme.outline
                border.width: 1
                clip: true
                focus: ControlCenterService.visible
                Keys.onEscapePressed: root.controlCenterService.visible = false

                MouseArea {
                    anchors.fill: parent
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: Theme.spacingLarge

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing

                        ColumnLayout {
                            spacing: 2

                            Text {
                                font.family: Theme.fontFamily
                                text: "Control Center"
                                color: Theme.text
                                font.pixelSize: Theme.fontSizeTitle
                                font.weight: Font.DemiBold
                            }

                            Text {
                                id: dateLabel
                                font.family: Theme.fontFamily
                                text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
                                color: Theme.textSecondary
                                font.pixelSize: Theme.fontSizeSmall

                                Timer {
                                    interval: 60000
                                    running: controlCenterWindow.visible
                                    repeat: true
                                    onTriggered: dateLabel.text = Qt.formatDateTime(new Date(), "dddd, MMMM d")
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            implicitWidth: 34
                            implicitHeight: 34
                            radius: 17
                            color: closeArea.containsMouse ? Theme.surfaceContainerHigh : Theme.surfaceContainer

                            QsIcon {
                                anchors.centerIn: parent
                                icon: Icons.x
                                size: 16
                                color: Theme.textSecondary
                            }

                            MouseArea {
                                id: closeArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.controlCenterService.visible = false
                            }
                        }
                    }

                    RowLayout {
                        visible: controlCenterWindow.currentPage !== 0
                        Layout.fillWidth: true
                        QsButton {
                            text: "‹  Home"
                            onClicked: controlCenterWindow.currentPage = 0
                        }
                        Text {
                            text: ({
                                    4: "Audio",
                                    5: "Network",
                                    6: "Bluetooth"
                                })[controlCenterWindow.currentPage] || ""
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: 18
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                    }
                    StackLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        currentIndex: controlCenterWindow.currentPage === 0 ? 0 : controlCenterWindow.currentPage - 3
                        Flickable {
                            clip: true
                            contentWidth: width
                            contentHeight: home.implicitHeight
                            boundsBehavior: Flickable.StopAtBounds
                            ColumnLayout {
                                id: home
                                width: parent.width
                                spacing: 16
                                Text {
                                    text: "QUICK SETTINGS"
                                    color: Theme.textSecondary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.letterSpacing: 2
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10
                                    QsSummaryCard {
                                        title: "Network"
                                        icon: Icons.wifiHigh
                                        subtitle: root.networkService.connectionName
                                        active: root.networkService.isConnected
                                        onClicked: controlCenterWindow.currentPage = 5
                                    }
                                    QsSummaryCard {
                                        title: "Bluetooth"
                                        icon: "\ue0da"
                                        subtitle: root.bluetoothService.enabled ? "接続済み " + root.bluetoothService.devices.filter(d => d.connected).length + " 台" : "オフ"
                                        active: root.bluetoothService.enabled
                                        onClicked: controlCenterWindow.currentPage = 6
                                    }
                                    QsSummaryCard {
                                        title: "Audio"
                                        icon: Icons.volumeHigh
                                        subtitle: root.volumeService.muted ? "ミュート" : Math.round(root.volumeService.volume * 100) + "% · " + root.volumeService.sinkName
                                        active: !root.volumeService.muted
                                        onClicked: controlCenterWindow.currentPage = 4
                                    }
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 78
                                    radius: 16
                                    color: Theme.surfaceContainer
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 16
                                        spacing: 14
                                        QsButton {
                                            text: root.volumeService.muted ? "消音中" : "音量"
                                            onClicked: root.volumeService.toggleMute()
                                        }
                                        QsSlider {
                                            Layout.fillWidth: true
                                            from: 0
                                            to: 1
                                            value: root.volumeService.volume
                                            onMoved: value => root.volumeService.setVolume(value)
                                        }
                                        Text {
                                            text: Math.round(root.volumeService.volume * 100) + "%"
                                            color: Theme.text
                                            font.family: Theme.fontFamily
                                            Layout.preferredWidth: 40
                                        }
                                    }
                                }
                                Text {
                                    text: "NOW PLAYING"
                                    color: Theme.textSecondary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.letterSpacing: 2
                                }
                                MediaControl {}
                                RowLayout {
                                    Layout.fillWidth: true
                                    QsButton {
                                        text: root.notificationService.dnd ? "通知を再開" : "応答不可"
                                        onClicked: root.notificationService.dnd = !root.notificationService.dnd
                                    }
                                    QsButton {
                                        text: "通知  " + root.notificationService.history.count + "  ›"
                                        onClicked: {
                                            root.controlCenterService.visible = false;
                                            root.notificationService.panelVisible = true;
                                        }
                                    }
                                    Item {
                                        Layout.fillWidth: true
                                    }
                                    QsButton {
                                        text: "ロック"
                                        onClicked: {
                                            root.controlCenterService.visible = false;
                                            PowerService.lock();
                                        }
                                    }
                                }
                                ThemeSwitcher {
                                    Layout.fillWidth: true
                                }
                            }
                        }
                        AudioPage {
                            volumeService: root.volumeService
                        }
                        NetworkPage {
                            networkService: root.networkService
                        }
                        BluetoothPage {
                            bluetoothService: root.bluetoothService
                        }
                    }
                }
            }
        }
    }
}
