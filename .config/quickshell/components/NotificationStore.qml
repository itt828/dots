pragma Singleton
import QtQuick
import Quickshell.Services.Notifications

Item {
    id: root
    
    property ListModel history: ListModel {}
    readonly property alias server: serverInstance

    NotificationServer {
        id: serverInstance
        keepOnReload: false
        imageSupported: true
        actionsSupported: true
        
        onNotification: notification => {
            // Add to beginning of history
            root.history.insert(0, { "notificationObj": notification })
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