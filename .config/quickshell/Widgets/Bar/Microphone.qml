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

    property bool isMuted: VolumeService.sourceMuted
    onIsMutedChanged: highlight.flash()

    HighlightEffect {
        id: highlight
    }

    IconLabel {
        id: display
        anchors.centerIn: parent
        icon: isMuted ? FontIcons.microphoneSlash : FontIcons.microphone
        color: isMuted ? Theme.danger : "black"
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: VolumeService.toggleSourceMute()
    }
}
