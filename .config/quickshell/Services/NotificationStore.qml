pragma Singleton
import QtQuick
import Quickshell.Services.Notifications

Item {
    id: root
    
    property ListModel history: ListModel {}
    property bool dnd: false
    readonly property alias server: serverInstance

    NotificationServer {
        id: serverInstance
        keepOnReload: false
        imageSupported: true
        actionsSupported: true
        
        onNotification: notification => {
            console.log("Notification received:", notification.appName, notification.summary, "Icon:", notification.icon, "Image:", notification.image)
            // Add to beginning of history
            root.history.insert(0, {
                "notificationObj": notification,
                "appName": notification.appName || "System",
                "summary": notification.summary || "",
                "body": notification.body || "",
                "icon": notification.icon || "",
                "appIcon": notification.appIcon || "",
                "image": notification.image || ""
            })
            root.notificationReceived(notification)
        }
    }
    
    signal notificationReceived(var notification)
    
    function dismiss(index) {
        if (index >= 0 && index < history.count) {
            var n = history.get(index).notificationObj
            if (n && n.close) n.close()
            history.remove(index)
        }
    }
    
    function clearAll() {
        for(var i=0; i<history.count; i++) {
             var n = history.get(i).notificationObj
             if (n && n.close) n.close()
        }
        history.clear()
    }
}