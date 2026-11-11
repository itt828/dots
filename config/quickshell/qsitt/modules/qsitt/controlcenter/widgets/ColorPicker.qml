import QtQuick
import QtQuick.Layouts
import qs.modules.common.theme

Rectangle {
    id: root

    required property var controlCenterService

    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 24
    radius: 8
    color: Theme.surface

    RowLayout {
        id: content
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
            color: root.controlCenterService.pickedColor !== "" ? root.controlCenterService.pickedColor : Theme.primaryContainer
            border.width: 1
            border.color: Theme.outline
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Text {
            font.family: Theme.fontFamily
                Layout.fillWidth: true
                text: "カラーピッカー"
                color: Theme.text
                font.bold: true
            }

            Text {
            font.family: Theme.fontFamily
                Layout.fillWidth: true
                text: root.controlCenterService.pickerStatus
                color: root.controlCenterService.pickerBusy ? Theme.accent : Theme.textSecondary
                font.pointSize: 9
                wrapMode: Text.Wrap
            }
        }

        Text {
            font.family: Theme.fontFamily
            text: root.controlCenterService.pickerBusy ? "…" : "実行"
            color: root.controlCenterService.pickerBusy ? Theme.outline : Theme.accent
            font.bold: true
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: !root.controlCenterService.pickerBusy
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.controlCenterService.pickColor()
    }
}
