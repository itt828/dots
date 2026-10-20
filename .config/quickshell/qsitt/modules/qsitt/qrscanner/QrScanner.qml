pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.modules.common.theme
import qs.services

Scope {
    id: root
    readonly property var controlCenterService: ControlCenterService

    Variants {
        model: Quickshell.screens.filter(screen => SettingsService.targetScreens.length === 0 || SettingsService.targetScreens.includes(screen.name))

        PanelWindow {
            id: selector
            required property var modelData
            screen: modelData
            visible: root.controlCenterService.qrSelecting
            color: Theme.withAlpha(Theme.text, 0.2)
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            property real startX: 0
            property real startY: 0
            property real currentX: 0
            property real currentY: 0

            Rectangle {
                x: Math.min(selector.startX, selector.currentX)
                y: Math.min(selector.startY, selector.currentY)
                width: Math.abs(selector.currentX - selector.startX)
                height: Math.abs(selector.currentY - selector.startY)
                color: Theme.withAlpha(Theme.primary, 0.13)
                border.color: Theme.primary
                border.width: 2
                visible: selectionArea.pressed
            }

            Text {
            font.family: Theme.fontFamily
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                    topMargin: 32
                }
                text: "QRコードをドラッグで囲む • 右クリックでキャンセル"
                color: Theme.primaryText
                font.bold: true
                style: Text.Outline
                styleColor: "#80000000"
            }

            MouseArea {
                id: selectionArea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.CrossCursor

                onPressed: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        root.controlCenterService.cancelQrSelection();
                        return;
                    }
                    selector.startX = mouse.x;
                    selector.startY = mouse.y;
                    selector.currentX = mouse.x;
                    selector.currentY = mouse.y;
                }
                onPositionChanged: mouse => {
                    if (pressed && pressedButtons & Qt.LeftButton) {
                        selector.currentX = mouse.x;
                        selector.currentY = mouse.y;
                    }
                }
                onReleased: mouse => {
                    if (mouse.button !== Qt.LeftButton)
                        return;
                    const x = Math.round(Math.min(selector.startX, mouse.x) + (selector.modelData.x || 0));
                    const y = Math.round(Math.min(selector.startY, mouse.y) + (selector.modelData.y || 0));
                    const width = Math.round(Math.abs(mouse.x - selector.startX));
                    const height = Math.round(Math.abs(mouse.y - selector.startY));
                    if (width < 4 || height < 4) {
                        root.controlCenterService.cancelQrSelection();
                        return;
                    }
                    root.controlCenterService.finishQrSelection(x + "," + y + " " + width + "x" + height);
                }
            }
        }
    }

}
