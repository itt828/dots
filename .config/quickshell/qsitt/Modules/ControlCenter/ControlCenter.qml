pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

Scope {
    id: root

    readonly property var controlCenterService: ControlCenterService
    readonly property var volumeService: VolumeService
    readonly property var networkService: NetworkService
    readonly property var bluetoothService: BluetoothService
    readonly property var notificationService: NotificationService

    IpcHandler {
        target: "control-center"

        function toggle(): string {
            ControlCenterService.toggle();
            return ControlCenterService.visible ? "visible" : "hidden";
        }

        function open(): string {
            ControlCenterService.visible = true;
            return ControlCenterService.visible ? "visible" : "hidden";
        }

        function close(): string {
            ControlCenterService.visible = false;
            return ControlCenterService.visible ? "visible" : "hidden";
        }
    }

    Variants {
        model: Quickshell.screens.filter(screen => SettingsData.targetScreens.length === 0 || SettingsData.targetScreens.includes(screen.name))

        PanelWindow {
            id: controlCenterWindow

            required property var modelData
            property int currentPage: 0

            screen: modelData
            visible: true
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Top

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
                    horizontalCenter: parent.horizontalCenter
                }

                width: Math.min(720, parent.width - 32)
                height: Math.min(560, parent.height - anchors.topMargin - 20)
                color: Theme.surface
                radius: Theme.radiusLarge
                border.color: Theme.outline
                border.width: 1
                clip: true

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
                                text: "Control Center"
                                color: Theme.text
                                font.pixelSize: Theme.fontSizeTitle
                                font.weight: Font.DemiBold
                            }

                            Text {
                                id: dateLabel
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

                        Item { Layout.fillWidth: true }

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

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: 12
                        color: Theme.surfaceContainer

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 5
                            spacing: 4

                            Repeater {
                                model: ["Home", "Alerts", "Media", "Tools", "Audio", "Network", "Bluetooth"]

                                delegate: Rectangle {
                                    required property int index
                                    required property string modelData

                                    readonly property bool selected: controlCenterWindow.currentPage === index

                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: Theme.radius
                                    color: selected ? Theme.primary : (tabArea.containsMouse ? Theme.surfaceContainerHigh : "transparent")

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData
                                        color: parent.selected ? Theme.primaryText : Theme.textSecondary
                                        font.pixelSize: Theme.fontSizeSmall
                                        font.weight: parent.selected ? Font.DemiBold : Font.Medium
                                    }

                                    MouseArea {
                                        id: tabArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: controlCenterWindow.currentPage = index
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 14
                        color: Theme.surfaceContainer
                        clip: true

                        StackLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingLarge
                            currentIndex: controlCenterWindow.currentPage

                            ColumnLayout {
                                spacing: Theme.spacing
                                CalendarWidget {}
                                Item { Layout.fillHeight: true }
                            }

                            NotificationHistory {
                                notificationService: root.notificationService
                            }

                            ColumnLayout {
                                spacing: Theme.spacing
                                MediaControl {}
                                Item { Layout.fillHeight: true }
                            }

                            ToolList {
                                controlCenterService: root.controlCenterService
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
}
