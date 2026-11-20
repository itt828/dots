import QtQuick
import qs.ui.theme
import QtQuick.Layouts
import "."

Rectangle {
    id: root
    property string text: ""
    property string icon: ""
    signal clicked

    Layout.fillWidth: true
    height: 40
    color: mouseArea.pressed ? Theme.mustard200 : mouseArea.containsMouse ? Theme.hover : "transparent"
    radius: 6
    scale: mouseArea.pressed ? 0.97 : 1
    Behavior on scale {
        QsNumberAnimation {
            duration: Theme.motionFast
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10

        QsIcon {
            icon: root.icon
            size: 16
            visible: root.icon !== ""
        }

        Text {
            font.family: Theme.fontFamily
            text: root.text
            color: Theme.textPrimary
            Layout.fillWidth: true
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
        cursorShape: Qt.PointingHandCursor
    }
}
