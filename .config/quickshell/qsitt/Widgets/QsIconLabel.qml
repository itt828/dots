import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Widgets

Item {
    id: root

    property alias icon: iconItem.icon
    property alias text: textItem.text
    property alias spacing: layout.spacing
    property alias iconSize: iconItem.size
    property color color: Theme.text

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight
    width: implicitWidth
    height: implicitHeight

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 6

        QsIcon {
            id: iconItem
            color: root.color
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            id: textItem
            color: root.color
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeBody
            visible: text !== ""
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
