import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "../Assets"

Scope {
    id: root
    required property var dashboardContext
    property string processError: ""

    Variants {
        model: Quickshell.screens.filter(screen => Config.targetScreens.length === 0 || Config.targetScreens.includes(screen.name))

        PanelWindow {
            id: selector
            required property var modelData
            screen: modelData
            visible: root.dashboardContext.qrSelecting
            color: "#33000000"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay

            anchors { top: true; bottom: true; left: true; right: true }

            property real startX: 0
            property real startY: 0
            property real currentX: 0
            property real currentY: 0

            Rectangle {
                x: Math.min(selector.startX, selector.currentX)
                y: Math.min(selector.startY, selector.currentY)
                width: Math.abs(selector.currentX - selector.startX)
                height: Math.abs(selector.currentY - selector.startY)
                color: "#2274b9ff"
                border.color: "#74b9ff"
                border.width: 2
                visible: selectionArea.pressed
            }

            Text {
                anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 32 }
                text: "QRコードをドラッグで囲む • 右クリックでキャンセル"
                color: "white"
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
                        root.dashboardContext.cancelQrSelection()
                        return
                    }
                    selector.startX = mouse.x
                    selector.startY = mouse.y
                    selector.currentX = mouse.x
                    selector.currentY = mouse.y
                }
                onPositionChanged: mouse => {
                    if (pressed && pressedButtons & Qt.LeftButton) {
                        selector.currentX = mouse.x
                        selector.currentY = mouse.y
                    }
                }
                onReleased: mouse => {
                    if (mouse.button !== Qt.LeftButton)
                        return
                    const x = Math.round(Math.min(selector.startX, mouse.x) + (selector.modelData.x || 0))
                    const y = Math.round(Math.min(selector.startY, mouse.y) + (selector.modelData.y || 0))
                    const width = Math.round(Math.abs(mouse.x - selector.startX))
                    const height = Math.round(Math.abs(mouse.y - selector.startY))
                    if (width < 4 || height < 4) {
                        root.dashboardContext.cancelQrSelection()
                        return
                    }
                    root.dashboardContext.finishQrSelection(x + "," + y + " " + width + "x" + height)
                }
            }
        }
    }

    Process {
        id: qrProcess
        running: root.dashboardContext.qrBusy
        command: ["bash", "-c", `
            value="$(grim -g "$1" -t png - | zbarimg --quiet --raw - 2>/dev/null)"
            [ -n "$value" ] || exit 30
            printf %s "$value" | wl-copy || exit 40
            command -v notify-send >/dev/null && notify-send 'QRコード' 'クリップボードにコピーしました'
        `, "qr-reader", root.dashboardContext.qrGeometry]

        stderr: StdioCollector {
            onStreamFinished: root.processError = text.trim().slice(0, 160)
        }

        onExited: (exitCode, exitStatus) => {
            root.dashboardContext.qrBusy = false
            if (exitCode === 0)
                root.dashboardContext.qrStatus = "QRコードの内容をクリップボードにコピーしました"
            else if (exitCode === 30)
                root.dashboardContext.qrStatus = "選択範囲にQRコードが見つかりませんでした"
            else
                root.dashboardContext.qrStatus = "QRコードの読み取りに失敗しました"
            if (exitCode !== 0) {
                if (root.processError !== "")
                    root.dashboardContext.qrStatus += "（" + root.processError + "）"
                root.dashboardContext.visible = true
            }
        }
    }
}
