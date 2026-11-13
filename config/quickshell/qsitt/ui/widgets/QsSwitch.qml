import QtQuick
import qs.ui.theme

Rectangle {
    id: root
    property bool checked: false
    signal toggled(bool checked)
    implicitWidth: 46
    implicitHeight: 28
    radius: 14
    color: checked ? Theme.primary : Theme.surfaceContainerHigh
    opacity: enabled ? 1 : 0.4
    activeFocusOnTab: true
    border.width: activeFocus ? 2 : 0
    border.color: Theme.text
    function toggle() {
        toggled(!checked);
    }
    Rectangle {
        x: root.checked ? root.width - width - 4 : 4
        anchors.verticalCenter: parent.verticalCenter
        width: 20
        height: 20
        radius: 10
        color: root.checked ? Theme.primaryText : Theme.textSecondary
        Behavior on x {
            NumberAnimation {
                duration: 140
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggle()
    }
    Keys.onSpacePressed: toggle()
}
