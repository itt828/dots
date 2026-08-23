import QtQuick
import QtQuick.Layouts
import "../../Components"

Item {
    id: root

    property alias icon: iconItem.icon
    property alias text: textItem.text
    property alias spacing: layout.spacing
    property alias iconSize: iconItem.size
    property color color: "black"

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight
    width: implicitWidth
    height: implicitHeight

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 6

        AIcon {
            id: iconItem
            color: root.color
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            id: textItem
            color: root.color
            visible: text !== ""
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
