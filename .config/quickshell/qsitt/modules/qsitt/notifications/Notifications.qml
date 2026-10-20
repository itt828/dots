pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services

PanelWindow {
    id: root

    readonly property var notificationService: NotificationService

    anchors {
        top: true
        right: true
    }

    implicitWidth: 320
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
        target: notificationService

        function onNotificationReceived(notification) {
            if (notificationService.dnd)
                return;
            popupModel.append({
                "notificationObj": notification,
                "appName": notification.appName || "System",
                "summary": notification.summary || "",
                "body": notification.body || "",
                "icon": notification.icon || "",
                "appIcon": notification.appIcon || "",
                "image": notification.image || ""
            });
        }
    }

    function removePopup(notification) {
        for (var i = 0; i < popupModel.count; i++) {
            if (popupModel.get(i).notificationObj === notification) {
                popupModel.remove(i);
                break;
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
                required property var model

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
