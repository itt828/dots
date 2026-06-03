import QtQuick
import QtQuick.Layouts
import Quickshell
import "../Services"
import "./Notification"

PanelWindow {
    id: root

    required property var notificationStore

    anchors {
        top: true
        right: true
    }

    width: 320
    implicitHeight: popupList.implicitHeight + 20

    color: "transparent"

    margins {
        top: 10
        right: 10
    }

    ListModel {
        id: popupModel
    }

    Connections {
        target: notificationStore

        function onNotificationReceived(notification) {
            if (notificationStore.dnd) return
            popupModel.append({
                "notificationObj": notification,
                "appName": notification.appName || "System",
                "summary": notification.summary || "",
                "body": notification.body || "",
                "icon": notification.icon || "",
                "appIcon": notification.appIcon || "",
                "image": notification.image || ""
            })
        }
    }

    function removePopup(notification) {
        for (var i = 0; i < popupModel.count; i++) {
            if (popupModel.get(i).notificationObj === notification) {
                popupModel.remove(i)
                break
            }
        }
    }

    ColumnLayout {
        id: popupList
        width: parent.width
        spacing: 10

        Repeater {
            model: popupModel

            delegate: NotificationPopup {
                Layout.fillWidth: true
                notification: model.notificationObj
                appName: model.appName
                summary: model.summary
                body: model.body
                appIconSource: model.appIcon
                iconSource: model.icon
                imageSource: model.image
                isPopup: true

                onClosed: root.removePopup(notification)
            }
        }
    }
}
