import QtQuick
import qs.ui.theme

Rectangle {
    id: root
    property real from: 0
    property real to: 1
    property real value: 0
    implicitWidth: 160
    implicitHeight: 4
    radius: 2
    color: Theme.surfaceContainerHigh
    Rectangle {
        width: parent.width * Math.max(0, Math.min(1, (root.value - root.from) / (root.to - root.from || 1)))
        height: parent.height
        radius: 2
        color: Theme.primary
    }
}
