pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Item {
    id: root

    property ListModel history: ListModel {}
    property bool dnd: false
    property bool panelVisible: false
    property string panelOutput: ""
    readonly property var panelScreens: Quickshell.screens.filter(screen => SettingsService.targetScreens.length === 0 || SettingsService.targetScreens.includes(screen.name))
    readonly property string visiblePanelOutput: panelScreens.some(screen => screen.name === panelOutput) ? panelOutput : (panelScreens[0]?.name ?? "")

    function preview(): void {
        sample.running = true;
    }

    Process {
        id: sample
        command: ["notify-send", "--app-name=kalumiru", "サンプル通知", "下のバーは通知が消えるまでの残り時間です。"]
    }

    function openFor(output: string): void {
        SearchService.close();
        ControlCenterService.visible = false;
        PowerService.visible = false;
        panelOutput = output;
        panelVisible = true;
    }

    function toggleFor(output: string): void {
        if (panelVisible && (!output || output === visiblePanelOutput))
            panelVisible = false;
        else
            openFor(output);
    }
    readonly property alias server: serverInstance

    NotificationServer {
        id: serverInstance
        keepOnReload: false
        imageSupported: true
        actionsSupported: true

        onNotification: notification => {
            notification.tracked = true;
            if (SettingsService.notificationHistory && !notification.transient)
                root.history.insert(0, {
                    "notificationObj": notification,
                    "appName": notification.appName || "System",
                    "summary": notification.summary || "",
                    "body": notification.body || "",
                    "icon": notification.icon || "",
                    "appIcon": notification.appIcon || "",
                    "image": notification.image || ""
                });
            root.notificationReceived(notification);
        }
    }

    signal notificationReceived(var notification)

    function disposeIfUnstored(notification: var): void {
        if (!notification)
            return;
        for (let index = 0; index < history.count; index++) {
            if (history.get(index).notificationObj === notification)
                return;
        }
        notification.dismiss();
    }

    function dismiss(index) {
        if (index >= 0 && index < history.count) {
            var n = history.get(index).notificationObj;
            if (n && n.dismiss)
                n.dismiss();
            history.remove(index);
        }
    }

    function clearAll() {
        for (var i = 0; i < history.count; i++) {
            var n = history.get(i).notificationObj;
            if (n && n.dismiss)
                n.dismiss();
        }
        history.clear();
    }
}
