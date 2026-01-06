import QtQuick
import Quickshell
import "UI"

Item {
    id: root
    width: display.width
    height: display.height
    implicitWidth: display.implicitWidth
    implicitHeight: display.implicitHeight

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    BarValue {
        id: display
        // Seconds as progress
        value: clock.seconds / 60.0

        // iconName: FontIcons.clock
        showLabel: true
        labelText: Qt.formatDateTime(clock.date, "yyyy/MM/dd  HH:mm")

        progressColor: "black"
        trackColor: "#aaaaaa"
    }
}
