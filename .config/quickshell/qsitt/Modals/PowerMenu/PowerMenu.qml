pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Services
import qs.Widgets
import qs.Common

Scope {
    id: root

    Variants {
        model: Quickshell.screens.filter(screen => SettingsData.targetScreens.length === 0 || SettingsData.targetScreens.includes(screen.name))

        PanelWindow {
            id: powerMenuWindow
            required property var modelData
            screen: modelData

            visible: PowerService.visible

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            color: "transparent"

            MouseArea {
                anchors.fill: parent
                onClicked: PowerService.visible = false
            }

            Rectangle {
                id: menuContent

                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 60
                anchors.rightMargin: 16

                width: 180
                height: contentCol.implicitHeight + 20
                color: "#eeeeee"
                radius: 12
                border.color: "#6f8792"
                border.width: 2

                MouseArea {
                    anchors.fill: parent
                }

                ColumnLayout {
                    id: contentCol
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 2

                    QsPowerOption {
                        text: "Lock"
                        icon: Icons.lock
                        onClicked: {
                            PowerService.visible = false;
                            PowerService.lock();
                        }
                    }

                    QsPowerOption {
                        text: "Shutdown"
                        icon: Icons.power
                        onClicked: {
                            PowerService.visible = false;
                            shutdownProc.running = true;
                        }
                    }

                    QsPowerOption {
                        text: "Reboot"
                        icon: Icons.power
                        onClicked: {
                            PowerService.visible = false;
                            rebootProc.running = true;
                        }
                    }

                    QsPowerOption {
                        text: "Suspend"
                        icon: Icons.power
                        onClicked: {
                            PowerService.visible = false;
                            // 即座にロックとサスペンドを実行
                            PowerService.lock();
                            suspendProc.running = true;
                        }
                    }

                    QsPowerOption {
                        text: "Exit"
                        icon: Icons.power
                        onClicked: {
                            PowerService.visible = false;
                            logoutProc.running = true;
                        }
                    }
                }
            }
        }
    }

    Process {
        id: shutdownProc
        command: ["systemctl", "poweroff"]
    }

    Process {
        id: rebootProc
        command: ["systemctl", "reboot"]
    }

    Process {
        id: suspendProc
        command: ["systemctl", "suspend"]
    }

    Process {
        id: lockSessionProc
        command: ["loginctl", "lock-session"]
    }

    Process {
        id: lockProc
    }

    Process {
        id: logoutProc
        command: ["loginctl", "terminate-user", ""]
    }
}
