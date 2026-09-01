import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../Assets"
import "./Dashboard"

Scope {
    id: root
    required property var dashboardContext
    property var volumeService
    property var networkService
    property var bluetoothService
    property var notificationStore

    Variants {
        model: Quickshell.screens.filter(screen => Config.targetScreens.length === 0 || Config.targetScreens.includes(screen.name))

        PanelWindow {
            id: dashboardWindow
            required property var modelData
            screen: modelData

            visible: dashboardContext.visible
            // slurp uses the Wayland Overlay layer. Keep the dashboard on Top so
            // its transparent fullscreen surface can never cover the selector.
            WlrLayershell.layer: WlrLayer.Top
            onVisibleChanged: {
                if (visible && volumeService) {
                    volumeService.refreshProfile();
                }
            }

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"

            MouseArea {
                anchors.fill: parent
                onClicked: dashboardContext.visible = false
            }

            Rectangle {
                id: dashboardContent

                anchors.top: parent.top
                anchors.topMargin: 56
                anchors.horizontalCenter: parent.horizontalCenter

                width: 640
                height: layout.implicitHeight + 32
                color: "#c4d0d6"
                radius: 8
                border.color: "#6f8792"
                border.width: 2

                MouseArea {
                    anchors.fill: parent
                }

                ColumnLayout {
                    id: layout
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: 16
                    }
                    spacing: 12
                    property int currentIndex: 0

                    // Tab Switcher
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Repeater {
                            model: ["Home", "Notifications", "Media", "Tools", "Audio", "Network", "Bluetooth"]
                            Rectangle {
                                Layout.fillWidth: true
                                height: 32
                                radius: 6
                                color: layout.currentIndex === index ? "#ffffff" : "#b0bec5"

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.bold: layout.currentIndex === index
                                    color: layout.currentIndex === index ? "black" : "#455a64"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: layout.currentIndex = index
                                }
                            }
                        }
                    }

                    // Pages
                    StackLayout {
                        currentIndex: layout.currentIndex
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // Home Page
                        ColumnLayout {
                            spacing: 12
                            CalendarWidget {}
                        }

                        // Notifications Page
                        ColumnLayout {
                            spacing: 12
                            NotificationHistory {
                                Layout.fillHeight: true
                                Layout.minimumHeight: 240
                                notificationStore: root.notificationStore
                            }
                        }

                        // Media Page
                        ColumnLayout {
                            spacing: 12
                            MediaControl {}
                            Item {
                                Layout.fillHeight: true
                            } // Spacer
                        }

                        // Tools Page
                        ToolList {
                            dashboardContext: root.dashboardContext
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
