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
        model: Quickshell.screens

        PanelWindow {
            id: powerMenuWindow
            required property var modelData
            screen: modelData
            visible: PowerService.visible || menuContent.reveal > 0
            mask: dismissArea.inputRegion

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: menuContent.shown ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            WlrLayershell.namespace: "kalumiru:power-menu"
            BackgroundEffect.blurRegion: Region {
                item: menuContent.blurActive ? menuContent : null
                radius: menuContent.radius
            }

            QsPopupDismissArea {
                id: dismissArea

                output: powerMenuWindow.modelData
                enabled: PowerService.visible
                onPressed: PowerService.visible = false
            }

            QsWindowShadow {
                surface: menuContent
            }

            QsPopupSurface {
                id: menuContent
                readonly property int inset: Theme.barOuterMargin
                readonly property real lowerY: Math.max(Theme.barHeight + inset, PowerService.lowerAnchor.y + inset)
                readonly property bool opensAbove: lowerY + height + inset > powerMenuWindow.modelData.height

                shown: PowerService.visible && PowerService.outputName === powerMenuWindow.modelData.name
                transformOrigin: opensAbove ? Item.BottomRight : Item.TopRight
                entryX: 0
                entryY: opensAbove ? 10 : -10
                x: Math.max(inset, Math.min(PowerService.lowerAnchor.x - width, powerMenuWindow.modelData.width - width - inset))
                y: opensAbove ? Math.max(inset, PowerService.upperAnchor.y - height - inset) : lowerY
                width: Math.min(180, powerMenuWindow.modelData.width - 2 * inset)
                height: contentCol.implicitHeight + 20
                focus: shown
                Keys.onEscapePressed: PowerService.visible = false

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
