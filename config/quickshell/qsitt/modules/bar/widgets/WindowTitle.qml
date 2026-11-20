import QtQuick
import qs.ui.widgets
import qs.ui.theme

QsMarqueeText {
    required property var windowService

    visible: text !== ""
    text: windowService.focusedWindowTitle
    color: Theme.muted
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSizeBody
}
