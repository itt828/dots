import QtQuick
import qs.ui.theme
import qs.ui.widgets

Rectangle {
    id: root

    required property var searchService

    implicitWidth: 26
    implicitHeight: 24
    radius: Theme.radiusSmall
    color: clickArea.containsMouse ? Theme.surfaceContainerHigh : "transparent"
    scale: clickArea.pressed ? 0.9 : 1
    Behavior on scale {
        QsNumberAnimation {
            duration: Theme.motionFast
        }
    }
    Behavior on color {
        QsColorAnimation {}
    }

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
