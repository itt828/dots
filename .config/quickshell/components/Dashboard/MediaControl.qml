import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris
import "../UI"

Rectangle {
    id: root
    color: "#dddddd"
    radius: 12
    height: 100
    Layout.fillWidth: true

    property var currentPlayer: Mpris.mediaPlayers.length > 0 ? Mpris.mediaPlayers[0] : null

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Album Art
        Rectangle {
            Layout.preferredWidth: 80
            Layout.preferredHeight: 80
            radius: 8
            color: "#bbbbbb"
            clip: true

            Image {
                anchors.fill: parent
                source: root.currentPlayer ? root.currentPlayer.metadata["mpris:artUrl"] : ""
                fillMode: Image.PreserveAspectCrop
                visible: source != ""
            }
            
            // Placeholder Icon if no art
            AIcon {
                anchors.centerIn: parent
                size: 40
                icon: FontIcons.mediaMusic
                visible: parent.children[0].status !== Image.Ready
                opacity: 0.5
            }
        }

        // Info & Controls
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            AText {
                text: root.currentPlayer ? (root.currentPlayer.metadata["xesam:title"] || "No Title") : "No Media"
                font.bold: true
                font.pixelSize: 14
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            AText {
                text: root.currentPlayer ? (root.currentPlayer.metadata["xesam:artist"] || "Unknown Artist") : "-"
                font.pixelSize: 12
                opacity: 0.7
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            // Controls
            RowLayout {
                visible: !!root.currentPlayer
                spacing: 15
                Layout.topMargin: 5

                // Previous
                AIcon {
                    icon: FontIcons.mediaPrev
                    size: 24
                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (root.currentPlayer) root.currentPlayer.previous()
                    }
                }

                // Play/Pause
                AIcon {
                    icon: root.currentPlayer && root.currentPlayer.playbackStatus === MprisPlaybackStatus.Playing
                            ? FontIcons.mediaPause
                            : FontIcons.mediaPlay
                    size: 24
                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (root.currentPlayer) root.currentPlayer.playPause()
                    }
                }

                // Next
                AIcon {
                    icon: FontIcons.mediaNext
                    size: 24
                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (root.currentPlayer) root.currentPlayer.next()
                    }
                }
            }
        }
    }
}
