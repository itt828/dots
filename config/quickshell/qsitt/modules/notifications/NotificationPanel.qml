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
            visible: NotificationService.panelVisible
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            MouseArea {
                anchors.fill: parent
                onClicked: NotificationService.panelVisible = false
            }
            Rectangle {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                    topMargin: Theme.barHeight + Theme.barOuterMargin + 12
                    bottomMargin: 16
                    rightMargin: 16
                }
                width: Math.min(460, parent.width - 32)
                color: Theme.surface
                radius: 22
                border.color: Theme.outlineVariant
                border.width: 1
                focus: true
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
                                text: "通知センター"
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
                        text: NotificationService.dnd ? "応答不可 · オン" : "応答不可 · オフ"
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
