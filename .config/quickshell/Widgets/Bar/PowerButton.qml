import QtQuick
import "../../Components"
import "../../Assets"
import "../../Services"

Item {
    id: root
    width: icon.width
    height: icon.height
    implicitWidth: icon.width
    implicitHeight: icon.height

    AIcon {
        id: icon
        icon: FontIcons.power
        size: 16
        
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: PowerContext.toggle()
        }
    }
}
