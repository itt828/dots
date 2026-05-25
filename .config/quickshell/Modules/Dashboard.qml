import Quickshell
import QtQuick
import QtQuick.Effects
import "../Services"
import "../Common"
import "./Dashboard"

Scope {
    Variants {
        model: Quickshell.screens.filter(screen => Config.targetScreens.length === 0 || Config.targetScreens.includes(screen.name))

        PanelWindow {
            id: dashboardWindow
            required property var modelData
            screen: modelData

            visible: DashboardContext.visible

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            color: "transparent"

            MouseArea {
                anchors.fill: parent
                onClicked: DashboardContext.visible = false
            }
            Rectangle {
                id: dashboardContent

                x: 16
                y: 60

                width: 340
                height: parent.height - 120
                color: "#eeeeee"
                radius: 16
                border.color: "#cccccc"
                border.width: 1

                MouseArea {
                    anchors.fill: parent
                }

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: "black"
                    shadowOpacity: 0.3
                    shadowBlur: 10
                }

                DashboardContent {
                    id: contentCol
                    anchors.fill: parent
                    anchors.margins: 10
                }
            }
        }
    }
}