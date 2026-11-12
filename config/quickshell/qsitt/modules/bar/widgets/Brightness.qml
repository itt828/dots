import QtQuick
import qs.ui.widgets
import qs.ui.theme
import qs.services

Item {
    id: root
    implicitWidth: display.implicitWidth + 8
    implicitHeight: display.implicitHeight + 6
    width: implicitWidth
    height: implicitHeight

    required property var brightnessService
    property real brightnessVal: brightnessService.brightness
    onBrightnessValChanged: highlight.flash()

    QsHighlightEffect {
        id: highlight
    }

    QsIconLabel {
        id: display
        anchors.centerIn: parent
        text: Math.round(root.brightnessVal * 100) + "%"
        icon: Icons.sunDim
    }
}
