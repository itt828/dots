import QtQuick
import qs.ui.widgets
import qs.ui.theme
import qs.services

Rectangle {
    id: root
    implicitWidth: display.implicitWidth + 20
    implicitHeight: 28
    width: implicitWidth
    height: implicitHeight
    radius: height / 2
    color: Theme.surfaceContainerHigh
    Behavior on color { QsColorAnimation {} }

    required property var brightnessService
    property real brightnessVal: brightnessService.brightness
    onBrightnessValChanged: highlight.flash()

    QsHighlightEffect {
        id: highlight
        cornerRadius: root.radius
    }

    QsIconLabel {
        id: display
        anchors.centerIn: parent
        text: Math.round(root.brightnessVal * 100) + "%"
        icon: Icons.sunDim
    }
}
