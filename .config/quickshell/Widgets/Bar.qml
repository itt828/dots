import Quickshell
import QtQuick
import QtQuick.Layouts
import "../Services"
import "../Assets"
import "./Bar"

Scope {
    id: root
    required property var services

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
                    Workspaces {
                        workspaceStore: services.workspaces
                        outputName: barWindow.screen.name
                    }
                    WindowTitle {
                        windowService: services.windows
                    }
                }

                centerContent: Clock {
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: services.dashboard.toggle()
                    }
                }

                rightContent: RowLayout {
                    spacing: 8
                    Tray {
                        rootWindow: barWindow
                    }
                    Notifications {
                        notificationStore: services.notifications
                    }
                    Volume {
                        volumeService: services.volume
                    }
                    Microphone {
                        volumeService: services.volume
                    }
                    Brightness {
                        brightnessService: services.brightness
                    }
                    Cpu {
                        cpuService: services.cpu
                    }
                    Mem {
                        memService: services.mem
                    }
                    Network {
                        networkService: services.network
                    }
                    Battery {}
                    PowerButton {
                        powerContext: services.power
                    }
                }
            }
        }
    }
}
