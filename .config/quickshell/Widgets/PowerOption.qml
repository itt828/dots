import QtQuick
import QtQuick.Layouts
import "."

Rectangle {
    id: root
    property string text: ""
    property string icon: ""
    signal clicked()

    Layout.fillWidth: true
    height: 40
    color: mouseArea.containsMouse ? "#dddddd" : "transparent"
    radius: 6

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10

        AIcon {
            icon: root.icon
            size: 16
            visible: root.icon !== ""
        }

        AText {
            text: root.text
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
