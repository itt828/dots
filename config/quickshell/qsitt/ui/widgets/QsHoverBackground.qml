import QtQuick
import qs.ui.theme

Rectangle {
    property bool hovered: false

    anchors.fill: parent
    radius: 8
    color: Theme.hover
    opacity: hovered ? 1 : 0

    Behavior on opacity {
        QsNumberAnimation {
            duration: Theme.motionFast
        }
    }
}
