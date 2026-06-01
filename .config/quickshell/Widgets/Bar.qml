import Quickshell
import QtQuick
import QtQuick.Layouts
import "../Services"
import "../Assets"
import "./Bar"

Scope {
    id: root

    Variants {
        model: Quickshell.screens.filter((screen, index) => {
            if (Config.targetScreens.length > 0) {
                return Config.targetScreens.includes(screen.name);
            }
            return index === 0;
        })

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
            implicitHeight: bar.implicitHeight+16

            Base {
                id: bar
                implicitHeight: 32

                leftContent: RowLayout {
                    spacing: 16
                    Workspaces {}
                    WindowTitle {}
                }

                centerContent: Clock {
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: DashboardContext.toggle()
                    }
                }

                rightContent: RowLayout {
                    spacing: 8
                    Tray {
                        rootWindow: barWindow
                    }
                    Notifications {}
                    Volume {}
                    Microphone {}
                    Brightness {}
                    // Cpu {}
                    // Mem {}
                    Network {}
                    Battery {}
                    PowerButton {}
                }
            }
        }
    }
}
