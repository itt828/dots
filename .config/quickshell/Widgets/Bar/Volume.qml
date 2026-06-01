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

    onCurrentVolumeChanged: highlight.flash()
    onIsMutedChanged: highlight.flash()

    property real currentVolume: VolumeService.volume
    property bool isMuted: VolumeService.muted

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
}

