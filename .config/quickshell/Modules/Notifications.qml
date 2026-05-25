import QtQuick
import "../Widgets"
import "../Services"
import "../Common"

Item {
    id: root
    width: display.width
    height: display.height
    implicitWidth: display.implicitWidth
    implicitHeight: display.implicitHeight

    BarValue {
        id: display
        value: 0
        trackColor: "transparent"
        progressColor: "black"

        iconName: NotificationStore.dnd ? FontIcons.bellSlash : (NotificationStore.history.count > 0 ? FontIcons.bellRinging : FontIcons.bell)
        showLabel: true
        labelText: NotificationStore.history.count

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: NotificationStore.dnd = !NotificationStore.dnd
        }
    }
}
