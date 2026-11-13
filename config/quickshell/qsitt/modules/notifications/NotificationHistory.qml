pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.services
import qs.ui.widgets
import qs.ui.theme

Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.minimumHeight: 200
    color: "transparent"
    radius: 14
    border.color: Theme.outline
    border.width: 0
    clip: true

    required property var notificationService

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: Theme.spacing

        // Header
        RowLayout {
            Layout.fillWidth: true
            Text {
                font.family: Theme.fontFamily
                text: "履歴  ·  " + root.notificationService.history.count
                color: Theme.text
                font.pixelSize: 16
                font.weight: Font.DemiBold
                Layout.fillWidth: true
            }
            QsButton {
                text: "すべて消去"
                visible: root.notificationService.history.count > 0
                onClicked: root.notificationService.clearAll()
            }
        }

        // List
        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: root.notificationService.history

            delegate: NotificationPopup {
                required property var model
                required property int index
                width: list.width
                notification: model.notificationObj
                appName: model.appName
                summary: model.summary
                body: model.body
                appIconSource: model.appIcon
                iconSource: model.icon
                imageSource: model.image
                isPopup: false // Full view in history

                onClosed: root.notificationService.dismiss(index)

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
                color: Theme.textSecondary
            }
        }
    }
}
