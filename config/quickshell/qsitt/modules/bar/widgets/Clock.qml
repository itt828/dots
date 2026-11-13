import QtQuick
import Quickshell
import qs.ui.theme

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
        font.weight: Font.DemiBold
        anchors.fill: parent
        text: Qt.formatDateTime(clock.date, "M/d ddd   HH:mm")
    }
}
