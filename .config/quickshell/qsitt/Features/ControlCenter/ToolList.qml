import QtQuick
import QtQuick.Layouts
import qs.Theme

ColumnLayout {
    id: root

    required property var controlCenterService
    spacing: 10

    Text {
            font.family: Theme.fontFamily
        text: "Tools"
        color: Theme.text
        font.bold: true
        font.pointSize: 12
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: toolContent.implicitHeight + 24
        radius: 8
        color: Theme.surface

        RowLayout {
            id: toolContent
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: 12
            }
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 42
                Layout.preferredHeight: 42
                radius: 8
                color: Theme.primaryContainer

                Text {
            font.family: Theme.fontFamily
                    anchors.centerIn: parent
                    text: "QR"
                    color: Theme.accent
                    font.bold: true
                    font.pointSize: 10
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                Text {
            font.family: Theme.fontFamily
                    Layout.fillWidth: true
                    text: "QRコードを範囲から読み取る"
                    color: Theme.text
                    font.bold: true
                }

                Text {
            font.family: Theme.fontFamily
                    Layout.fillWidth: true
                    text: root.controlCenterService.qrStatus
                    color: root.controlCenterService.qrBusy ? Theme.accent : Theme.textSecondary
                    font.pointSize: 9
                    wrapMode: Text.Wrap
                }
            }

            Text {
            font.family: Theme.fontFamily
                text: root.controlCenterService.qrBusy ? "…" : "実行"
                color: root.controlCenterService.qrBusy ? "#90a4ae" : Theme.accent
                font.bold: true
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: !root.controlCenterService.qrBusy && !root.controlCenterService.qrSelecting
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                root.controlCenterService.startQrSelection();
            }
        }
    }

    ColorPicker {
        controlCenterService: root.controlCenterService
    }

    TimerStopwatch {
        controlCenterService: root.controlCenterService
    }

    Text {
            font.family: Theme.fontFamily
        Layout.fillWidth: true
        text: "範囲・色の選択をキャンセルするには Esc キーを押します。"
        color: Theme.textSecondary
        font.pointSize: 9
        wrapMode: Text.Wrap
    }

    Item {
        Layout.fillHeight: true
    }
}
