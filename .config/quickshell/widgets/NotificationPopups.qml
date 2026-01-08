import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import "../components"

PanelWindow {
    id: root
    
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
        target: NotificationStore
        
        function onNotificationReceived(notification) {
            popupModel.append({ "notificationObj": notification })
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
                isPopup: true
                
                onClosed: root.removePopup(notification)
            }
        }
    }
}