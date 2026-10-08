import QtQuick
import qs.Theme
import qs.Widgets

Rectangle {
    id: root

    required property var searchService

    implicitWidth: 26
    implicitHeight: 24
    radius: Theme.radiusSmall
    color: clickArea.containsMouse ? Theme.surfaceContainerHigh : "transparent"

    QsIcon {
        anchors.centerIn: parent
        icon: Icons.search
        size: 16
        color: Theme.text
    }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.searchService.toggle()
    }
}
