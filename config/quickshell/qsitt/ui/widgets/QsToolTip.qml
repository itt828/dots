import QtQuick
import qs.ui.theme

Item {
    id: root
    property string text: ""
    property bool hovered: false
    property real reveal: hovered && delay.ready ? 1 : 0
    visible: reveal > 0
    opacity: reveal
    Behavior on reveal {
        QsNumberAnimation {
            duration: Theme.motionFast
        }
    }
    implicitWidth: label.implicitWidth + 20
    implicitHeight: label.implicitHeight + 16
    x: Math.min(0, parent.width - width)
    y: parent.height + 10 - 3 * (1 - reveal)
    z: 100
    QsWindowShadow {
        surface: background
    }
    Rectangle {
        id: background
        anchors.fill: parent
        color: Theme.surfaceContainerHigh
        radius: 8
    }
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
