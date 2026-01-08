import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../components" // For NotificationPopup delegate and Store
import "../UI"

Rectangle {
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.minimumHeight: 200
    color: "#dddddd"
    radius: 12
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 5

        // Header
        RowLayout {
            Layout.fillWidth: true
            AText {
                text: "Notifications"
                font.bold: true
                Layout.fillWidth: true
            }
            AIcon {
                icon: "edit-clear-all" // or trash
                size: 20
                visible: NotificationStore.history.count > 0
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NotificationStore.clearAll()
                }
            }
        }

        // List
        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: NotificationStore.history

            delegate: NotificationPopup {
                width: list.width
                notification: model.notificationObj
                isPopup: false // Full view in history
                
                // Add a close button logic for history items if needed, 
                // NotificationPopup has a close button but it closes the notification object.
                // We might want to just remove from history or close.
            }
            
            // Empty State
            AText {
                anchors.centerIn: parent
                text: "No new notifications"
                visible: list.count === 0
                opacity: 0.5
            }
        }
    }
}
