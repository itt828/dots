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

    HighlightEffect {
        id: highlight
    }

    Connections {
        target: NotificationStore
        function onDndChanged() { highlight.flash() }
    }

    // Monitor history count changes
    property int lastCount: NotificationStore.history.count
    onLastCountChanged: {
        highlight.flash()
    }

    IconLabel {
        id: display
        anchors.centerIn: parent
        icon: NotificationStore.dnd ? FontIcons.bellSlash : (NotificationStore.history.count > 0 ? FontIcons.bellRinging : FontIcons.bell)
        text: NotificationStore.history.count.toString()
        
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: NotificationStore.dnd = !NotificationStore.dnd
        }
    }
}
