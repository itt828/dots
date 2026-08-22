import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import "../Assets"
import "./Dashboard"

Scope {
    id: root
    required property var dashboardContext
    property var volumeService
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
            }
            implicitWidth: 380
            implicitHeight: dashboardContent.height + 20
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"

            Rectangle {
                id: dashboardContent

                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter

                width: 360
                height: layout.implicitHeight + 32
                color: "#c4d0d6"
                radius: 8

                MouseArea {
                    anchors.fill: parent
                }

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: "#ee7e9da8"
                    shadowOpacity: 1
                    shadowBlur: 0
                    shadowHorizontalOffset: 8
                    shadowVerticalOffset: 8
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
                            model: ["Home", "Media", "Tools"]
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

                    // Audio Profile Switcher
                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        radius: 8
                        color: "#ffffff"
                        visible: volumeService !== undefined && volumeService.alsaCardName !== ""

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12

                            Text {
                                text: "Audio Profile"
                                font.bold: true
                                color: "#37474f"
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Item { Layout.fillWidth: true } // Spacer

                            RowLayout {
                                spacing: 8
                                Layout.alignment: Qt.AlignVCenter

                                Text {
                                    text: "🎧 Headphones"
                                    font.pointSize: 9
                                    color: volumeService.isHeadphones ? "#37474f" : "#90a4ae"
                                    font.bold: volumeService.isHeadphones
                                }

                                // Toggle Switch
                                Rectangle {
                                    width: 40
                                    height: 20
                                    radius: 10
                                    color: "#cfd8dc"
                                    
                                    Rectangle {
                                        id: handle
                                        width: 16
                                        height: 16
                                        radius: 8
                                        color: "#455a64"
                                        anchors.verticalCenter: parent.verticalCenter
                                        x: volumeService.isSpeaker ? 22 : 2
                                        
                                        Behavior on x {
                                            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (volumeService) {
                                                volumeService.toggleProfile();
                                            }
                                        }
                                    }
                                }

                                Text {
                                    text: "🔊 Speaker"
                                    font.pointSize: 9
                                    color: volumeService.isSpeaker ? "#37474f" : "#90a4ae"
                                    font.bold: volumeService.isSpeaker
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
                            Item { Layout.fillHeight: true } // Spacer
                        }

                        // Tools Page
                        ToolList {
                            dashboardContext: root.dashboardContext
                        }
                    }
                }
            }
        }
    }
}
