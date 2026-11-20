import QtQuick
import qs.ui.theme

Item {
    id: root
    property string icon: ""
    property int size: 16
    property color color: Theme.ink

    implicitWidth: size
    implicitHeight: size
    width: size
    height: size

    Text {
        anchors.fill: parent
        font.family: Icons.fontFamily
        font.pixelSize: root.size
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: root.icon
        color: root.color
    }
}
