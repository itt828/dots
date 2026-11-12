import QtQuick
import QtQuick.Layouts
import qs.ui.widgets
import qs.services
import qs.ui.theme

Item {
    id: root
    width: layout.implicitWidth
    height: layout.implicitHeight
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    required property var windowService

    RowLayout {
        id: layout

        Text {
            text: windowService.focusedWindowTitle
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeBody
            color: Theme.text
            elide: Text.ElideRight
            Layout.maximumWidth: 300
        }
    }
}
