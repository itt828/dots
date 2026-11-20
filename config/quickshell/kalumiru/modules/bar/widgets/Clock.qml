import QtQuick
import Quickshell
import qs.ui.theme
import qs.ui.widgets

QsButton {
    text: clock.date.toLocaleString(Qt.locale("ja_JP"), "M月d日（ddd） HH:mm")
    variant: QsButton.Ghost
    horizontalPadding: 8
    toolTip: "カレンダー"

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
