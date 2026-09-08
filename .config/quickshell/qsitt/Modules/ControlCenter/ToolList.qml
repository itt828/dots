import QtQuick
import QtQuick.Layouts
import qs.Common

ColumnLayout {
    id: root

    required property var controlCenterService
    spacing: 10

    Text {
        text: "Tools"
        color: "#37474f"
        font.bold: true
        font.pointSize: 12
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: toolContent.implicitHeight + 24
        radius: 8
        color: "#ffffff"

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
                color: "#e3f2fd"

                Text {
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
                    Layout.fillWidth: true
                    text: "QRコードを範囲から読み取る"
                    color: "#263238"
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    text: root.controlCenterService.qrStatus
                    color: root.controlCenterService.qrBusy ? Theme.accent : "#607d8b"
                    font.pointSize: 9
                    wrapMode: Text.Wrap
                }
            }

            Text {
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

    TimerStopwatch {}

    Text {
        Layout.fillWidth: true
        text: "範囲・色の選択をキャンセルするには Esc キーを押します。"
        color: "#607d8b"
        font.pointSize: 9
        wrapMode: Text.Wrap
    }

    Item {
        Layout.fillHeight: true
    }
}
