pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.ui.theme
import qs.services

PanelWindow {
    id: root

    readonly property var notificationService: NotificationService

    anchors {
        top: true
        right: true
    }

    visible: popupModel.count > 0 && !notificationService.panelVisible
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    implicitWidth: 400
    implicitHeight: Math.min(popupList.implicitHeight + 20, screen.height - 100)

    color: "transparent"

    margins {
        top: Theme.barHeight + Theme.barOuterMargin + 14
        right: 10
    }

    ListModel {
        id: popupModel
    }

    Connections {
        target: notificationService

        function onNotificationReceived(notification) {
            if (notificationService.dnd || notificationService.panelVisible)
                return;
            if (popupModel.count >= 3)
                popupModel.remove(0);
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
