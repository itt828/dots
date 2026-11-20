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
    Layout.minimumHeight: 60
    color: "transparent"
    radius: 14
    border.color: Theme.border
    border.width: 0
    clip: true

    required property var notificationService

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: Theme.spacing

        RowLayout {
            Layout.fillWidth: true
            Text {
                font.family: Theme.fontFamily
                text: "履歴  ·  " + root.notificationService.history.count
                color: Theme.textPrimary
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

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: root.notificationService.history
            add: Transition {
                QsNumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                }
            }
            remove: Transition {
                QsNumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: Theme.motionExit
                }
            }
            displaced: Transition {
                QsNumberAnimation {
                    properties: "x,y"
                }
            }

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
            }

            Text {
                font.family: Theme.fontFamily
                anchors.centerIn: parent
                text: "新しい通知はありません"
                visible: list.count === 0
                color: Theme.textSecondary
            }
        }
    }
}
