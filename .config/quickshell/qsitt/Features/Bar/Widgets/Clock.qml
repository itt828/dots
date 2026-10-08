import QtQuick
import Quickshell
import qs.Theme

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
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeBody
        anchors.fill: parent
        text: Qt.formatDateTime(clock.date, "yyyy/MM/dd HH:mm")
    }
}
