import QtQuick
import qs.ui.widgets
import qs.ui.theme
import qs.services

Rectangle {
    id: root
    implicitWidth: display.implicitWidth + 16
    implicitHeight: 36
    width: implicitWidth
    height: implicitHeight
    radius: 8
    color: "transparent"

    required property var brightnessService
    property real brightnessVal: brightnessService.brightness
    onBrightnessValChanged: highlight.flash()

    QsHighlightEffect {
        id: highlight
        cornerRadius: root.radius
    }

    HoverHandler {
        id: statusHover
    }

    QsHoverBackground {
        hovered: statusHover.hovered
    }

    QsIconLabel {
        id: display
        hoverBackground: false
        hovered: statusHover.hovered
        anchors.centerIn: parent
        icon: Icons.sun
        text: Math.round(root.brightnessVal * 100) + "%"
    }
}
