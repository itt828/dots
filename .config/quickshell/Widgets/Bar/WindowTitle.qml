import QtQuick
import QtQuick.Layouts
import "../../Components"
import "../../Services"
import "../../Assets"

Item {
    id: root
    width: layout.implicitWidth
    height: layout.implicitHeight
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    RowLayout {
        id: layout
        
        Text {
            text: WindowService.focusedWindowTitle
            font.pixelSize: 13
            color: Theme.text
            elide: Text.ElideRight
            Layout.maximumWidth: 300
        }
    }
}
