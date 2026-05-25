import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../Services"
import "../Common"

Scope {
    id: root

    Variants {
        model: Quickshell.screens.filter(screen => Config.targetScreens.length === 0 || Config.targetScreens.includes(screen.name))

        PanelWindow {
            id: barWindow
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }
            color: "transparent"
            implicitHeight: barRect.implicitHeight + 16

            Rectangle {
                id: barRect
                color: "#c4d0d6" // oklch(0.85 0.015 228)

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    leftMargin: 16
                    rightMargin: 16
                    topMargin: 8
                }

                implicitHeight: layout.implicitHeight + 12

                bottomLeftRadius: 8
                bottomRightRadius: 8
                topLeftRadius: 8
                topRightRadius: 8

                layer {
                    enabled: true
                    effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: "#ee7e9da8"
                        shadowOpacity: 1
                        shadowBlur: 0
                        shadowHorizontalOffset: 8
                        shadowVerticalOffset: 8
                    }
                }

                Clock {
                    id: clockWidget
                    anchors.centerIn: parent

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: DashboardContext.toggle()
                    }
                }

                RowLayout {
                    id: layout
                    anchors {
                        fill: parent
                        leftMargin: 12
                        rightMargin: 12
                        topMargin: 0
                        bottomMargin: 0
                    }
                    spacing: 12

                    Item {
                        Layout.fillWidth: true
                    }

                    Notifications {}
                    Volume {}
                    Brightness {}
                    Cpu {}
                    Mem {}
                    Network {}
                    Battery {}
                    Tray {
                        rootWindow: barWindow
                    }
                    PowerButton {}
                }
            }
        }
    }
}
