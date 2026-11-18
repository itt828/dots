import QtQuick
import qs.ui.theme

Rectangle {
    id: root
    property string text: ""
    property string icon: ""
    property string toolTip: ""
    property bool checkable: false
    property bool highlighted: false
    signal clicked
    implicitWidth: icon !== "" && text === "" ? 36 : content.implicitWidth + 28
    implicitHeight: 36
    radius: 12
    opacity: enabled ? 1 : 0.4
    scale: area.pressed ? 0.95 : 1
    Behavior on scale {
        QsNumberAnimation {
            duration: Theme.motionFast
        }
    }
    Behavior on opacity {
        QsNumberAnimation {
            duration: Theme.motionFast
        }
    }
    color: area.pressed ? Theme.primaryContainer : highlighted ? Theme.primary : area.containsMouse ? Theme.surfaceContainerHigh : Theme.surfaceContainer
    border.width: activeFocus ? 2 : 0
    border.color: Theme.primary
    activeFocusOnTab: true
    Accessible.role: checkable ? Accessible.CheckBox : Accessible.Button
    Accessible.name: text || toolTip
    Accessible.checkable: checkable
    Accessible.checked: checkable && highlighted
    Accessible.onPressAction: root.clicked()
    Accessible.onToggleAction: root.clicked()
    Row {
        id: content
        anchors.centerIn: parent
        spacing: root.icon !== "" && root.text !== "" ? 8 : 0
        QsIcon {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon !== ""
            icon: root.icon
            size: 20
            color: root.highlighted ? Theme.primaryText : Theme.text
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.text !== ""
            text: root.text
            color: root.highlighted ? Theme.primaryText : Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
        }
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
    QsToolTip {
        text: root.toolTip
        hovered: root.toolTip !== "" && area.containsMouse
    }
    Behavior on color {
        QsColorAnimation {}
    }
}
