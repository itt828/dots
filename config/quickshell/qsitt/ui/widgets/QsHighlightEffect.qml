import QtQuick
import qs.ui.theme

Rectangle {
    id: root

    property color highlightColor: Theme.accent
    property real maxOpacity: 0.4
    property int flashInDuration: 100
    property int flashOutDuration: 500
    property int cornerRadius: 6

    anchors.fill: parent
    color: highlightColor
    opacity: 0
    radius: cornerRadius

    function flash() {
        if (Theme.motionEnabled)
            flashAnim.restart();
    }

    SequentialAnimation on opacity {
        id: flashAnim
        running: false
        NumberAnimation {
            to: root.maxOpacity
            duration: Math.round(root.flashInDuration * Theme.motionScale)
        }
        NumberAnimation {
            to: 0
            duration: Math.round(root.flashOutDuration * Theme.motionScale)
        }
    }
}
