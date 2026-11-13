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

    required property var volumeService
    property bool isMuted: volumeService.sourceMuted
    onIsMutedChanged: highlight.flash()

    QsHighlightEffect {
        id: highlight
    }

    QsIconLabel {
        id: display
        anchors.centerIn: parent
        icon: isMuted ? Icons.microphoneSlash : Icons.microphone
        color: isMuted ? Theme.danger : Theme.text
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: volumeService.toggleSourceMute()
        hoverEnabled: true
        QsToolTip { hovered: parent.containsMouse; text: root.volumeService.sourceName }
    }
}
