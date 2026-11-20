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
    scale: area.pressed ? 0.94 : 1
    Behavior on scale {
        QsNumberAnimation {
            duration: Theme.motionFast
        }
    }

    onCurrentVolumeChanged: highlight.flash()
    onIsMutedChanged: highlight.flash()

    required property string outputName
    required property var volumeService
    property real currentVolume: volumeService.volume
    property bool isMuted: volumeService.muted

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
        id: area
        anchors.fill: parent
        onClicked: ControlCenterService.openPage(4, root.outputName)
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        QsToolTip {
            hovered: parent.containsMouse
            text: root.volumeService.sinkName
        }
    }
}
