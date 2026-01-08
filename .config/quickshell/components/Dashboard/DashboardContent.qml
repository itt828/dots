import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 10
    width: 300 // default width

    MediaControl {}
    CalendarWidget {}
    NotificationHistory {
        Layout.fillHeight: true
    }
}