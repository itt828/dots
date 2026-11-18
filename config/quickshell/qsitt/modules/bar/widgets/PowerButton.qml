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
    scale: area.pressed ? 0.9 : 1
    Behavior on scale {
        QsNumberAnimation {
            duration: Theme.motionFast
        }
    }

    required property var powerService

    QsIcon {
        id: icon
        icon: Icons.power
        size: 16

        MouseArea {
            id: area
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: powerService.toggle()
        }
    }
}
