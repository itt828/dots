import QtQuick
import qs.modules.common.widgets
import qs.modules.common.theme
import qs.services

Item {
    id: root
    implicitWidth: display.implicitWidth + 8
    implicitHeight: display.implicitHeight + 6
    width: implicitWidth
    height: implicitHeight

    required property var notificationService

    QsHighlightEffect {
        id: highlight
    }

    Connections {
        target: notificationService
        function onDndChanged() {
            highlight.flash();
        }
    }

    // Monitor history count changes
    property int lastCount: notificationService.history.count
    onLastCountChanged: {
        highlight.flash();
    }

    QsIconLabel {
        id: display
        anchors.centerIn: parent
        icon: notificationService.dnd ? Icons.bellSlash : (notificationService.history.count > 0 ? Icons.bellRinging : Icons.bell)
        text: notificationService.history.count.toString()

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: notificationService.dnd = !notificationService.dnd
        }
    }
}
