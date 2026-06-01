import QtQuick
import "../../Components"
import "../../Assets"
import "../../Services"

Item {
    id: root
    implicitWidth: display.implicitWidth + 8
    implicitHeight: display.implicitHeight + 6
    width: implicitWidth
    height: implicitHeight

    property real brightnessVal: BrightnessService.brightness
    onBrightnessValChanged: highlight.flash()

    HighlightEffect {
        id: highlight
    }

    IconLabel {
        id: display
        anchors.centerIn: parent
        text: Math.round(root.brightnessVal * 100) + "%"
        icon: FontIcons.sunDim
    }
}
