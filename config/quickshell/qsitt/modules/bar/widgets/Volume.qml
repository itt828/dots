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
        onClicked: { ControlCenterService.requestedPage = 4; NotificationService.panelVisible = false; ControlCenterService.visible = true; }
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        QsToolTip { hovered: parent.containsMouse; text: root.volumeService.sinkName }
    }
}
