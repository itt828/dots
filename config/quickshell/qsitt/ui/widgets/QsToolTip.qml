import QtQuick
import qs.ui.theme

Rectangle {
    id: root
    property string text: ""
    property bool hovered: false
    visible: hovered && delay.ready
    implicitWidth: label.implicitWidth + 20
    implicitHeight: label.implicitHeight + 16
    x: Math.min(0, parent.width - width)
    y: parent.height + 10
    z: 100
    color: Theme.surfaceContainerHigh
    radius: 8
    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: 12
    }
    Timer {
        id: delay
        property bool ready: false
        interval: 500
        running: root.hovered
        onTriggered: ready = true
        onRunningChanged: if (!running)
            ready = false
    }
}
