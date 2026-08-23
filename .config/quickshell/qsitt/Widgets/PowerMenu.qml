import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../Services"
import "../Components"
import "../Assets"

Scope {
    required property var powerContext

    Variants {
        model: Quickshell.screens.filter(screen => Config.targetScreens.length === 0 || Config.targetScreens.includes(screen.name))

        PanelWindow {
            id: powerMenuWindow
            required property var modelData
            screen: modelData

            visible: powerContext.visible

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            color: "transparent"

            MouseArea {
                anchors.fill: parent
                onClicked: powerContext.visible = false
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

                    PowerOption {
                        text: "Lock"
                        icon: FontIcons.lock
                        onClicked: {
                            powerContext.visible = false;
                            powerContext.lock();
                        }
                    }

                    PowerOption {
                        text: "Shutdown"
                        icon: FontIcons.power
                        onClicked: {
                            powerContext.visible = false;
                            shutdownProc.running = true;
                        }
                    }

                    PowerOption {
                        text: "Reboot"
                        icon: FontIcons.power
                        onClicked: {
                            powerContext.visible = false;
                            rebootProc.running = true;
                        }
                    }

                    PowerOption {
                        text: "Suspend"
                        icon: FontIcons.power
                        onClicked: {
                            powerContext.visible = false;
                            // 即座にロックとサスペンドを実行
                            powerContext.lock();
                            suspendProc.running = true;
                        }
                    }

                    PowerOption {
                        text: "Exit"
                        icon: FontIcons.power
                        onClicked: {
                            powerContext.visible = false;
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
