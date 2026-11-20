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
    color: "transparent"
    scale: area.pressed ? 0.94 : 1
    Behavior on scale {
        QsNumberAnimation {
            duration: Theme.motionFast
        }
    }

    required property var volumeService
    property bool isMuted: volumeService.sourceMuted
    onIsMutedChanged: highlight.flash()

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
        icon: isMuted ? Icons.microphoneSlash : Icons.microphone
        color: isMuted ? Theme.error : Theme.textPrimary
    }

    MouseArea {
        id: area
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: volumeService.toggleSourceMute()
        hoverEnabled: true
        QsToolTip {
            hovered: parent.containsMouse
            text: root.volumeService.sourceName
        }
    }
}
