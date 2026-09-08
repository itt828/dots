import QtQuick
import QtQuick.Controls
import qs.Widgets
import qs.Common
import qs.Services

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
        color: isMuted ? Theme.danger : "black"
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: volumeService.toggleSourceMute()
        hoverEnabled: true
        ToolTip.visible: containsMouse
        ToolTip.text: volumeService.sourceName
        ToolTip.delay: 500
    }
}
