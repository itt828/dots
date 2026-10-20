import QtQuick
import qs.modules.common.widgets
import qs.modules.common.theme
import qs.services

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
