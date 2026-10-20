import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets
import qs.services
import qs.modules.common.theme

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
