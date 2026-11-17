import QtQuick
import qs.ui.theme

Item {
    id: root
    property real from: 0
    property real to: 1
    property real value: 0
    readonly property real fraction: Math.max(0, Math.min(1, (value - from) / (to - from || 1)))
    property real displayedFraction: fraction
    Behavior on displayedFraction {
        enabled: !area.dragging
        QsNumberAnimation { duration: Theme.motionFast }
    }
    signal moved(real value)
    implicitWidth: 160
    implicitHeight: 36
    activeFocusOnTab: true
    opacity: enabled ? 1 : 0.4
    Behavior on opacity { QsNumberAnimation {} }
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
            width: parent.width * root.displayedFraction
            height: parent.height
            radius: 3
            color: Theme.primary
        }
    }
    Rectangle {
        x: root.displayedFraction * (root.width - width)
        anchors.verticalCenter: parent.verticalCenter
        width: 18
        height: 18
        radius: 9
        color: Theme.primary
        border.width: root.activeFocus ? 3 : 0
        border.color: Theme.text
        scale: area.pressed ? 1.18 : area.containsMouse ? 1.08 : 1
        Behavior on scale { QsNumberAnimation { duration: Theme.motionFast } }
    }
    MouseArea {
        id: area
        property bool dragging: false
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: mouse => {
            dragging = true;
            root.setAt(mouse.x);
        }
        onReleased: dragging = false
        onCanceled: dragging = false
        onPositionChanged: mouse => {
            if (pressed)
                root.setAt(mouse.x);
        }
        onWheel: wheel => root.step(wheel.angleDelta.y > 0 ? 0.02 : -0.02)
    }
    Keys.onLeftPressed: step(-0.02)
    Keys.onRightPressed: step(0.02)
}
