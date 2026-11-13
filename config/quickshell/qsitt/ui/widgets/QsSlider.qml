import QtQuick
import qs.ui.theme

Item {
    id: root
    property real from: 0
    property real to: 1
    property real value: 0
    readonly property real fraction: Math.max(0, Math.min(1, (value - from) / (to - from || 1)))
    signal moved(real value)
    implicitWidth: 160
    implicitHeight: 36
    activeFocusOnTab: true
    opacity: enabled ? 1 : 0.4
    function setAt(x) {
        moved(from + Math.max(0, Math.min(1, (x - 9) / Math.max(1, width - 18))) * (to - from));
    }
    function step(delta) {
        moved(Math.max(from, Math.min(to, value + delta * (to - from))));
    }
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: 9
        width: parent.width - 18
        height: 6
        radius: 3
        color: Theme.surfaceContainerHigh
        Rectangle {
            width: parent.width * root.fraction
            height: parent.height
            radius: 3
            color: Theme.primary
        }
    }
    Rectangle {
        x: root.fraction * (root.width - width)
        anchors.verticalCenter: parent.verticalCenter
        width: 18
        height: 18
        radius: 9
        color: Theme.primary
        border.width: root.activeFocus ? 3 : 0
        border.color: Theme.text
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onPressed: mouse => root.setAt(mouse.x)
        onPositionChanged: mouse => {
            if (pressed)
                root.setAt(mouse.x);
        }
        onWheel: wheel => root.step(wheel.angleDelta.y > 0 ? 0.02 : -0.02)
    }
    Keys.onLeftPressed: step(-0.02)
    Keys.onRightPressed: step(0.02)
}
