import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../components"
import "../components/UI"

Scope {
    id: root

    Variants {
        model: Quickshell.screens
        // model: Quickshell.screens.filter(screen => ["eDP-1"].includes(screen.name))

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
            height: barRect.implicitHeight + 16

            Rectangle {
                id: barRect
                color: "#c4d0d6" // oklch(0.85 0.015 228)

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                implicitHeight: layout.implicitHeight + 12

                bottomLeftRadius: 8
                bottomRightRadius: 8

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: "black"
                    shadowOpacity: 0.25
                    shadowBlur: 0.8
                    shadowHorizontalOffset: 1
                    shadowVerticalOffset: 1
                    autoPaddingEnabled: true
                }

                RowLayout {
                    id: layout
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    anchors.topMargin: 6
                    anchors.bottomMargin: 6
                    spacing: 15

                    Clock {
                        id: clockWidget
                        Layout.alignment: Qt.AlignVCenter

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: DashboardContext.toggle()
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Volume {
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Brightness {
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Cpu {
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Mem {
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Battery {
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Tray {
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
        }
    }
}
