import QtQuick
import QtQuick.Controls
import "../../Components"
import "../../Assets"
import "../../Services"

Item {
    id: root
    implicitWidth: display.implicitWidth + 8
    implicitHeight: display.implicitHeight + 6
    width: implicitWidth
    height: implicitHeight

    onCurrentVolumeChanged: highlight.flash()
    onIsMutedChanged: highlight.flash()

    required property var volumeService
    property real currentVolume: volumeService.volume
    property bool isMuted: volumeService.muted

    HighlightEffect {
        id: highlight
    }

    IconLabel {
        id: display
        anchors.centerIn: parent
        text: Math.round(currentVolume * 100) + "%"

        icon: {
            if (isMuted) return FontIcons.volumeMuted
            if (currentVolume > 0.45) return FontIcons.volumeHigh
            if (currentVolume > 0.0) return FontIcons.volumeMedium
            return FontIcons.volumeLow
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        ToolTip.visible: containsMouse
        ToolTip.text: volumeService.sinkName
        ToolTip.delay: 500
    }
}

