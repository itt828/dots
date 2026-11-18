pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.services
import qs.ui.widgets
import qs.ui.theme

Scope {
    id: root

    Variants {
        model: Quickshell.screens.filter(screen => SettingsService.targetScreens.length === 0 || SettingsService.targetScreens.includes(screen.name))

        PanelWindow {
            id: powerMenuWindow
            required property var modelData
            screen: modelData
            visible: menuContent.shown || menuContent.reveal > 0
            mask: Region {
                item: menuContent.shown ? powerMenuWindow.contentItem : null
            }

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            color: "transparent"
            WlrLayershell.namespace: "qsitt:power-menu"
            BackgroundEffect.blurRegion: Region {
                item: menuContent.blurActive ? menuContent : null
                radius: menuContent.radius
            }

            MouseArea {
                anchors.fill: parent
                enabled: menuContent.shown
                onClicked: PowerService.visible = false
            }

            QsWindowShadow {
                surface: menuContent
            }

            QsPopupSurface {
                id: menuContent
                shown: PowerService.visible

                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: Theme.barHeight + 12
                anchors.rightMargin: 16

                width: 180
                height: contentCol.implicitHeight + 20
                color: Theme.glassPopup
                radius: 12
                border.color: Theme.glassOutline
                border.width: 1

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
