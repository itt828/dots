import QtQuick
import QtQuick.Controls
import qs.Widgets
import qs.Theme
import qs.Services

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

    QsHighlightEffect {
        id: highlight
    }

    QsIconLabel {
        id: display
        anchors.centerIn: parent
        text: Math.round(currentVolume * 100) + "%"

        icon: {
            if (isMuted)
                return Icons.volumeMuted;
            if (currentVolume > 0.45)
                return Icons.volumeHigh;
            if (currentVolume > 0.0)
                return Icons.volumeMedium;
            return Icons.volumeLow;
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
