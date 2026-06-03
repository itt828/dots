import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 10
    width: 300 // default width
    required property var notificationStore

    MediaControl {}
    CalendarWidget {}
    NotificationHistory {
        Layout.fillHeight: true
        notificationStore: parent.notificationStore
    }
}