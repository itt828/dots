import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.Widgets
import qs.Common

Rectangle {
    id: root
    color: "#dddddd"
    radius: 12
    height: 100
    Layout.fillWidth: true

    ListView {
        id: playerList
        model: Mpris.players
        anchors.fill: parent
        interactive: false
        clip: true

        delegate: RowLayout {
            width: playerList.width
            height: playerList.height
            anchors.margins: 10
            spacing: 10

            // Only show the first player for now (or could be improved to show active)
            visible: index === 0

            property var player: modelData

            // Album Art
            Rectangle {
                Layout.leftMargin: 10
                Layout.preferredWidth: 80
                Layout.preferredHeight: 80
                radius: 8
                color: "#bbbbbb"
                clip: true

                Image {
                    anchors.fill: parent
                    source: (player && player.metadata) ? (player.metadata["mpris:artUrl"] || "") : ""
                    fillMode: Image.PreserveAspectCrop
                    visible: source != ""
                }

                QsIcon {
                    anchors.centerIn: parent
                    size: 40
                    icon: Icons.mediaMusic
                    visible: !parent.children[0].visible || parent.children[0].status !== Image.Ready
                    opacity: 0.5
                }
            }

            // Info & Controls
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 4

                Text {
                    text: (player && player.metadata) ? (player.metadata["xesam:title"] || "No Title") : "No Media"
                    font.bold: true
                    font.pixelSize: 14
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: (player && player.metadata) ? (player.metadata["xesam:artist"] || "Unknown Artist") : "-"
                    font.pixelSize: 12
                    opacity: 0.7
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                // Controls
                RowLayout {
                    spacing: 15
                    Layout.topMargin: 5

                    QsIcon {
                        icon: Icons.mediaPrev
                        size: 24
                        MouseArea {
                            anchors.fill: parent
                            onClicked: player.previous()
                        }
                    }

                    QsIcon {
                        icon: player && player.playbackState === Mpris.Playing ? Icons.mediaPause : Icons.mediaPlay
                        size: 24
                        MouseArea {
                            anchors.fill: parent
                            onClicked: player.playPause()
                        }
                    }

                    QsIcon {
                        icon: Icons.mediaNext
                        size: 24
                        MouseArea {
                            anchors.fill: parent
                            onClicked: player.next()
                        }
                    }
                }
            }
        }

        // Fallback when no players exist
        Text {
            anchors.centerIn: parent
            text: "No Media"
            visible: playerList.count === 0
            opacity: 0.5
        }
    }
}
