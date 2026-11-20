import QtQuick
import qs.ui.theme

Rectangle {
    id: root
    property bool checked: false
    signal toggled(bool checked)
    implicitWidth: 36
    implicitHeight: 20
    radius: 10
    color: enabled ? (checked ? Theme.accent : Theme.border) : Theme.disabled
    opacity: enabled ? 1 : 0.4
    Behavior on color {
        QsColorAnimation {}
    }
    Behavior on opacity {
        QsNumberAnimation {}
    }
    activeFocusOnTab: true
    border.width: activeFocus ? 2 : 0
    border.color: Theme.focus
    function toggle() {
        toggled(!checked);
    }
    Rectangle {
        x: root.checked ? root.width - width - 2 : 2
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        height: 16
        radius: 8
        color: Theme.surface
        scale: area.pressed ? 0.9 : 1
        Behavior on scale {
            QsNumberAnimation {
                duration: Theme.motionFast
            }
        }
        Behavior on color {
            QsColorAnimation {}
        }
        Behavior on x {
            QsNumberAnimation {}
        }
    }
    MouseArea {
        id: area
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggle()
    }
    Keys.onSpacePressed: toggle()
}
