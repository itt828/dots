import QtQuick
import Quickshell

Item {
    id: root

    implicitWidth: clockText.implicitWidth
    implicitHeight: clockText.implicitHeight
    width: implicitWidth
    height: implicitHeight

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: clockText
        font.pixelSize: 14
        anchors.fill: parent
        text: Qt.formatDateTime(clock.date, "yyyy/MM/dd HH:mm")
    }
}
