import QtQuick
import qs.ui.widgets
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.services
import qs.ui.theme

Scope {
    IpcHandler {
        target: "notifications"
        function toggle(): void {
            ControlCenterService.visible = false;
            NotificationService.panelVisible = !NotificationService.panelVisible;
        }
        function close(): void {
            NotificationService.panelVisible = false;
        }
    }
    Variants {
        model: Quickshell.screens.filter(s => SettingsService.targetScreens.length === 0 || SettingsService.targetScreens.includes(s.name))
        PanelWindow {
            id: window
            required property var modelData
            screen: modelData
            visible: notificationContent.visible
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "qsitt:notifications"
            BackgroundEffect.blurRegion: Region {
                item: notificationContent.blurActive ? notificationContent : null
                radius: notificationContent.radius
            }
            WlrLayershell.keyboardFocus: notificationContent.shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            mask: Region {
                item: notificationContent.shown ? window.contentItem : null
            }
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            MouseArea {
                anchors.fill: parent
                enabled: notificationContent.shown
                onClicked: NotificationService.panelVisible = false
            }
            QsWindowShadow {
                surface: notificationContent
            }

            QsPopupSurface {
                id: notificationContent
                shown: NotificationService.panelVisible
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                    topMargin: Theme.barHeight + 12
                    bottomMargin: 16
                    rightMargin: 16
                }
                width: Math.min(460, parent.width - 32)
                color: Theme.glassPanel
                radius: 22
                border.color: Theme.glassOutline
                border.width: 1
                focus: shown
                Keys.onEscapePressed: NotificationService.panelVisible = false
                MouseArea {
                    anchors.fill: parent
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
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: 22
                                font.bold: true
                            }
                            Text {
                                text: Qt.formatDateTime(new Date(), "M月d日 dddd")
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        QsButton {
                            text: "閉じる"
                            onClicked: NotificationService.panelVisible = false
                        }
                    }
                    QsButton {
                        icon: NotificationService.dnd ? Icons.bellSlash : Icons.bell
                        highlighted: NotificationService.dnd
                        checkable: true
                        toolTip: NotificationService.dnd ? "応答不可: オン（クリックで通知を再開）" : "応答不可: オフ（クリックで通知を停止）"
                        onClicked: NotificationService.dnd = !NotificationService.dnd
                    }
                    NotificationHistory {
                        notificationService: NotificationService
                    }
                }
            }
        }
    }
}
