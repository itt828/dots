import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Services
import qs.Widgets
import qs.Theme
import qs.Features.Notifications

Rectangle {
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.minimumHeight: 200
    color: Theme.surface
    radius: 14
    border.color: Theme.outline
    border.width: 1
    clip: true

    required property var notificationService

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingLarge
        spacing: Theme.spacing

        // Header
        RowLayout {
            Layout.fillWidth: true
            Text {
            font.family: Theme.fontFamily
                text: "Notifications"
                color: Theme.text
                font.pixelSize: 16
                font.weight: Font.DemiBold
                Layout.fillWidth: true
            }
            QsIcon {
                icon: Icons.x
                size: 20
                visible: notificationService.history.count > 0
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: notificationService.clearAll()
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
            model: notificationService.history

            delegate: NotificationPopup {
                width: list.width
                notification: model.notificationObj
                appName: model.appName
                summary: model.summary
                body: model.body
                appIconSource: model.appIcon
                iconSource: model.icon
                imageSource: model.image
                isPopup: false // Full view in history

                // Add a close button logic for history items if needed,
                // NotificationPopup has a close button but it closes the notification object.
                // We might want to just remove from history or close.
            }

            // Empty State
            Text {
            font.family: Theme.fontFamily
                anchors.centerIn: parent
                text: "No new notifications"
                visible: list.count === 0
                opacity: 0.5
            }
        }
    }
}
