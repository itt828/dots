import QtQuick
import qs.Widgets
import qs.Common
import qs.Services

Item {
    id: root
    width: icon.width
    height: icon.height
    implicitWidth: icon.width
    implicitHeight: icon.height

    required property var powerService

    QsIcon {
        id: icon
        icon: Icons.power
        size: 16

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: powerService.toggle()
        }
    }
}
