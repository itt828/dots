import QtQuick
import QtQuick.Layouts
import qs.ui.theme
import qs.ui.widgets

Item {
    id: root

    property alias icon: iconItem.icon
    property alias text: textItem.text
    property alias spacing: layout.spacing
    property alias iconSize: iconItem.size
    property bool hoverBackground: true
    property bool hovered: pointer.hovered
    property int maximumTextWidth: 184
    property color color: Theme.ink
    Behavior on color {
        QsColorAnimation {}
    }

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight
    width: implicitWidth
    height: implicitHeight

    HoverHandler {
        id: pointer
    }

    QsHoverBackground {
        anchors.margins: -3
        hovered: root.hoverBackground && root.hovered
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 8

        QsIcon {
            id: iconItem
            color: root.color
            size: 20
            Layout.alignment: Qt.AlignVCenter
        }

        QsMarqueeText {
            id: textItem
            hovered: root.hovered
            color: root.color
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeBody
            font.weight: Font.Medium
            Layout.maximumWidth: root.maximumTextWidth
            visible: text !== ""
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
