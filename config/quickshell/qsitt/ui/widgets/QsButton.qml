import QtQuick
import qs.ui.theme

Rectangle {
    id: root
    property string text: ""
    property bool highlighted: false
    signal clicked
    implicitWidth: label.implicitWidth + 28
    implicitHeight: 36
    radius: 12
    opacity: enabled ? 1 : 0.4
    color: area.pressed ? Theme.primaryContainer : highlighted ? Theme.primary : area.containsMouse ? Theme.surfaceContainerHigh : Theme.surfaceContainer
    border.width: activeFocus ? 2 : 0
    border.color: Theme.primary
    activeFocusOnTab: true
    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.highlighted ? Theme.primaryText : Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: 12
        font.weight: Font.Medium
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
    Keys.onSpacePressed: clicked()
    Keys.onReturnPressed: clicked()
    Behavior on color {
        ColorAnimation {
            duration: 120
        }
    }
}
