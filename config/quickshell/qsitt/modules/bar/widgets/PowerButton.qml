import QtQuick
import qs.ui.widgets
import qs.ui.theme
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
