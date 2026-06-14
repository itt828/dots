import Quickshell
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import "../Assets"
import "./Dashboard"

Scope {
    id: root
    required property var dashboardContext

    Variants {
        model: Quickshell.screens.filter(screen => Config.targetScreens.length === 0 || Config.targetScreens.includes(screen.name))

        PanelWindow {
            id: dashboardWindow
            required property var modelData
            screen: modelData

            visible: dashboardContext.visible

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            color: "transparent"

            MouseArea {
                anchors.fill: parent
                onClicked: dashboardContext.visible = false
            }
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
                            model: ["Home", "Media"]
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
                    }
                }
            }
        }
    }
}
