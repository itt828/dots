import QtQuick
import qs.ui.theme

Item {
    id: root
    property real from: 0
    property real to: 1
    property real value: 0
    readonly property int thumbSize: 16
    readonly property real fraction: Math.max(0, Math.min(1, (value - from) / (to - from || 1)))
    property real displayedFraction: fraction
    Behavior on displayedFraction {
        enabled: !area.dragging
        QsNumberAnimation {
            duration: Theme.motionFast
        }
    }
    signal moved(real value)
    implicitWidth: 160
    implicitHeight: 24
    activeFocusOnTab: true
    Accessible.role: Accessible.Slider
    Accessible.onIncreaseAction: root.step(0.02)
    Accessible.onDecreaseAction: root.step(-0.02)
    opacity: enabled ? 1 : 0.4
    Behavior on opacity {
        QsNumberAnimation {}
    }
    function setAt(x) {
        moved(from + Math.max(0, Math.min(1, (x - thumbSize / 2) / Math.max(1, width - thumbSize))) * (to - from));
    }
    function step(delta) {
        moved(Math.max(from, Math.min(to, value + delta * (to - from))));
    }
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 4
        radius: 2
        color: Theme.borderPrimary
        Rectangle {
            width: root.thumbSize / 2 + (parent.width - root.thumbSize) * root.displayedFraction
            visible: root.displayedFraction > 0
            height: parent.height
            radius: 2
            color: Theme.mustard800
        }
    }
    Rectangle {
        x: root.displayedFraction * (root.width - width)
        anchors.verticalCenter: parent.verticalCenter
        width: root.thumbSize
        height: width
        radius: width / 2
        color: Theme.mustard800
        border.width: root.activeFocus ? 2 : 1
        border.color: Theme.focus
        scale: area.pressed ? 1.18 : area.containsMouse ? 1.08 : 1
        Behavior on scale {
            QsNumberAnimation {
                duration: Theme.motionFast
            }
        }
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
