pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.ui.theme
import qs.ui.widgets
import qs.services

PanelWindow {
    id: root

    readonly property var notificationService: NotificationService
    property real reveal: popupModel.count > 0 && !notificationService.panelVisible ? 1 : 0
    Behavior on reveal { QsNumberAnimation { duration: Theme.motionExit } }

    anchors {
        top: true
        right: true
    }

    visible: popupModel.count > 0 && (!notificationService.panelVisible || reveal > 0)
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qsitt:notification-popups"
    BackgroundEffect.blurRegion: Region {
        // Popups are capped at three; preserve the clear gaps between cards.
        Region {
            item: popupRepeater.count > 0 ? popupRepeater.itemAt(0).blurSurface : null
            radius: 16
        }
        Region {
            item: popupRepeater.count > 1 ? popupRepeater.itemAt(1).blurSurface : null
            radius: 16
        }
        Region {
            item: popupRepeater.count > 2 ? popupRepeater.itemAt(2).blurSurface : null
            radius: 16
        }
    }
    implicitWidth: 400 + Theme.windowShadowPadding * 2
    implicitHeight: Math.min(popupList.implicitHeight + Theme.windowShadowPadding * 2, screen.height - 100)
    mask: Region {
        item: root.notificationService.panelVisible ? null : popupList
    }

    color: "transparent"

    margins {
        top: Theme.barHeight + 14 - Theme.windowShadowPadding
        right: 0
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

    Column {
        id: popupList
        opacity: root.reveal
        x: Theme.windowShadowPadding
        y: Theme.windowShadowPadding
        width: parent.width - Theme.windowShadowPadding * 2
        spacing: 10
        move: Transition {
            QsNumberAnimation { properties: "x,y" }
        }

        Repeater {
            id: popupRepeater
            model: popupModel

            delegate: Item {
                id: popupDelegate
                required property var model
                readonly property Item blurSurface: popup.blurActive && !root.notificationService.panelVisible ? popup : null

                width: popupList.width
                implicitHeight: popup.implicitHeight
                height: implicitHeight

                QsWindowShadow {
                    surface: popup
                }

                NotificationPopup {
                    id: popup
                    width: parent.width
                    notification: popupDelegate.model.notificationObj
                    appName: popupDelegate.model.appName
                    summary: popupDelegate.model.summary
                    body: popupDelegate.model.body
                    appIconSource: popupDelegate.model.appIcon
                    iconSource: popupDelegate.model.icon
                    imageSource: popupDelegate.model.image
                    isPopup: true

                    onClosed: shown = false
                    onVisibleChanged: {
                        if (!visible && !shown)
                            root.removePopup(notification);
                    }
                }
            }
        }
    }
}
