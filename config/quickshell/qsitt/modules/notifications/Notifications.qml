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
    readonly property int shadowPadding: Theme.windowShadowPadding
    readonly property int trailingPadding: shadowPadding + Theme.toastSlide
    property int nextPopupId: 0
    property real reveal: popupModel.count > 0 && !notificationService.panelVisible ? 1 : 0
    Behavior on reveal {
        QsNumberAnimation {
            duration: root.notificationService.panelVisible ? Theme.motionExit : Theme.motionFast
        }
    }

    anchors {
        top: true
        right: true
    }

    visible: popupModel.count > 0 && (!notificationService.panelVisible || reveal > 0)
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qsitt:notification-popups"
    WlrLayershell.keyboardFocus: popupModel.count > 0 ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    implicitWidth: 382 + shadowPadding + trailingPadding
    implicitHeight: Math.max(1, Math.min(popupList.implicitHeight + shadowPadding * 2, (screen?.height ?? 1024) - 100))
    mask: Region {
        item: root.notificationService.panelVisible ? null : popupList
    }

    color: "transparent"

    margins {
        top: Theme.belowBar - root.shadowPadding
        right: Theme.popupInset - root.trailingPadding + (ControlCenterService.visible && root.screen?.name === ControlCenterService.visibleOutput ? Theme.controlWidth + 16 : 0)
    }

    ListModel {
        id: popupModel
    }

    Connections {
        target: notificationService

        function onDndChanged(): void {
            if (notificationService.dnd) {
                for (let index = 0; index < popupModel.count; ++index)
                    popupModel.setProperty(index, "closing", true);
            }
        }

        function onNotificationReceived(notification) {
            if (notificationService.dnd || notificationService.panelVisible) {
                notificationService.disposeIfUnstored(notification);
                return;
            }
            if (popupModel.count >= 3)
                root.removeAt(popupModel.count - 1);
            popupModel.insert(0, {
                "popupId": ++root.nextPopupId,
                "closing": false,
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

    function removeAt(index: int): void {
        const item = popupModel.get(index).notificationObj;
        popupModel.remove(index);
        notificationService.disposeIfUnstored(item);
    }

    function findPopup(id: int): int {
        for (let index = 0; index < popupModel.count; ++index) {
            if (popupModel.get(index).popupId === id)
                return index;
        }
        return -1;
    }

    function closePopup(id: int): void {
        const index = findPopup(id);
        if (index >= 0)
            popupModel.setProperty(index, "closing", true);
    }

    function removePopup(id: int): void {
        const index = findPopup(id);
        if (index >= 0)
            removeAt(index);
    }

    Column {
        id: popupList
        opacity: root.reveal
        x: root.shadowPadding
        y: root.shadowPadding
        width: parent.width - root.shadowPadding - root.trailingPadding
        spacing: 10
        move: Transition {
            QsNumberAnimation {
                properties: "x,y"
            }
        }

        Repeater {
            id: popupRepeater
            model: popupModel

            delegate: Item {
                id: popupDelegate
                required property var model

                width: popupList.width
                implicitHeight: popup.implicitHeight
                height: implicitHeight

                QsWindowShadow {
                    surface: popup
                    blur: 16
                    offset: Qt.vector2d(0, 8)
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
                    shown: !popupDelegate.model.closing
                    countdownVisible: !root.notificationService.panelVisible

                    readonly property bool exitFinished: !shown && reveal <= 0
                    onClosed: root.closePopup(popupDelegate.model.popupId)
                    onExitFinishedChanged: {
                        if (exitFinished)
                            Qt.callLater(root.removePopup, popupDelegate.model.popupId);
                    }
                }
            }
        }
    }
}
