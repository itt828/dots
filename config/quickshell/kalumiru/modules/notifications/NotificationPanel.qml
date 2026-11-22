import QtQuick
import qs.ui.widgets
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.modules.bar
import qs.services
import qs.ui.theme

Scope {
    id: root

    required property Bar bar

    IpcHandler {
        target: "notifications"
        function toggle(): void {
            ControlCenterService.visible = false;
            NotificationService.toggleFor("");
        }
        function close(): void {
            NotificationService.panelVisible = false;
        }
    }
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: window
            required property var modelData
            screen: modelData
            visible: (NotificationService.panelVisible && NotificationService.visiblePanelOutput !== "") || notificationContent.reveal > 0
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "kalumiru:notifications"
            BackgroundEffect.blurRegion: Region {
                item: notificationContent.blurActive ? notificationContent : null
                radius: notificationContent.radius
            }
            WlrLayershell.keyboardFocus: notificationContent.shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            mask: dismissArea.inputRegion
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            QsPopupDismissArea {
                id: dismissArea

                enabled: NotificationService.panelVisible && NotificationService.visiblePanelOutput !== ""
                passthroughRegion: root.bar.popupTriggerRegion(window.screen)
                onClicked: NotificationService.panelVisible = false
            }
            QsWindowShadow {
                surface: notificationContent
            }

            QsPopupSurface {
                id: notificationContent
                shown: NotificationService.panelVisible && NotificationService.visiblePanelOutput === window.modelData.name
                anchors {
                    top: parent.top
                    right: parent.right
                    topMargin: Theme.belowBar
                    rightMargin: Theme.popupInset
                }
                width: Math.max(1, Math.min(Theme.controlWidth, window.modelData.width - 2 * Theme.popupInset))
                height: Math.max(1, Math.min(window.modelData.height - anchors.topMargin - 16, 162 + NotificationService.history.count * 100))
                color: Theme.glassPanel
                radius: 22
                border.color: Theme.glassOutline
                border.width: 1
                Behavior on height {
                    enabled: notificationContent.shown && notificationContent.progress >= 0.99
                    QsNumberAnimation {}
                }
                focus: shown
                Keys.onEscapePressed: NotificationService.panelVisible = false
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.AllButtons
                }
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 14
                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            Text {
                                text: "通知"
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 22
                                font.bold: true
                            }
                            Text {
                                text: NotificationService.history.count + " 件の通知"
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        QsButton {
                            icon: Icons.settings
                            toolTip: "通知設定"
                            onClicked: ControlCenterService.openPage(7, window.modelData.name, "notifications")
                        }
                        QsButton {
                            text: "閉じる"
                            onClicked: NotificationService.panelVisible = false
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        QsIconLabel {
                            Layout.fillWidth: true
                            icon: NotificationService.dnd ? Icons.bellSlash : Icons.bell
                            text: "おやすみモード"
                        }
                        QsSwitch {
                            checked: NotificationService.dnd
                            Accessible.name: "おやすみモード"
                            onToggled: checked => NotificationService.dnd = checked
                        }
                    }
                    NotificationHistory {
                        notificationService: NotificationService
                    }
                }
            }
        }
    }
}
