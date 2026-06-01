import QtQuick
import "../Assets"

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
        flashAnim.restart()
    }

    SequentialAnimation on opacity {
        id: flashAnim
        running: false
        NumberAnimation { to: root.maxOpacity; duration: root.flashInDuration }
        NumberAnimation { to: 0; duration: root.flashOutDuration }
    }
}
