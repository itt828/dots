pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common.widgets
import qs.modules.common.theme

Scope {
    id: root

    Variants {
        model: Quickshell.screens.filter(screen => SettingsService.targetScreens.length === 0 || SettingsService.targetScreens.includes(screen.name))

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
                color: Theme.surfaceVariant
                radius: 12
                border.color: Theme.outline
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
                        onClicked: PowerService.powerOff()
                    }

                    QsPowerOption {
                        text: "Reboot"
                        icon: Icons.power
                        onClicked: PowerService.reboot()
                    }

                    QsPowerOption {
                        text: "Suspend"
                        icon: Icons.power
                        onClicked: PowerService.suspend()
                    }

                    QsPowerOption {
                        text: "Exit"
                        icon: Icons.power
                        onClicked: PowerService.logout()
                    }
                }
            }
        }
    }

}
