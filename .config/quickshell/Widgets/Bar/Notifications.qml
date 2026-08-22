import QtQuick
import "../../Components"
import "../../Assets"
import "../../Services"

Item {
    id: root
    implicitWidth: display.implicitWidth + 8
    implicitHeight: display.implicitHeight + 6
    width: implicitWidth
    height: implicitHeight

    required property var notificationStore

    HighlightEffect {
        id: highlight
    }

    Connections {
        target: notificationStore
        function onDndChanged() {
            highlight.flash();
        }
    }

    // Monitor history count changes
    property int lastCount: notificationStore.history.count
    onLastCountChanged: {
        highlight.flash();
    }

    IconLabel {
        id: display
        anchors.centerIn: parent
        icon: notificationStore.dnd ? FontIcons.bellSlash : (notificationStore.history.count > 0 ? FontIcons.bellRinging : FontIcons.bell)
        text: notificationStore.history.count.toString()

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: notificationStore.dnd = !notificationStore.dnd
        }
    }
}
