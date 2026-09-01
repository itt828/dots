import QtQuick
import "../../Widgets/Bar" as BarParts

Item {
    id: root
    required property var moduleContext

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    BarParts.Notifications {
        id: content
        anchors.centerIn: parent
        notificationStore: root.moduleContext.services.notifications
    }
}
