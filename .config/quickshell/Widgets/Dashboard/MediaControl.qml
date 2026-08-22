import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import "../../Components"
import "../../Assets"

Rectangle {
    id: root
    color: "#dddddd"
    radius: 12
    height: 100
    Layout.fillWidth: true

    Connections {
        target: Mpris.players
        function onCountChanged() {
            console.log("Mpris.players.count changed to:", Mpris.players.count);
        }
    }

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
                
                AIcon {
                    anchors.centerIn: parent
                    size: 40
                    icon: FontIcons.mediaMusic
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

                    AIcon {
                        icon: FontIcons.mediaPrev
                        size: 24
                        MouseArea {
                            anchors.fill: parent
                            onClicked: player.previous()
                        }
                    }

                    AIcon {
                        icon: player && player.playbackState === Mpris.Playing
                                ? FontIcons.mediaPause
                                : FontIcons.mediaPlay
                        size: 24
                        MouseArea {
                            anchors.fill: parent
                            onClicked: player.playPause()
                        }
                    }

                    AIcon {
                        icon: FontIcons.mediaNext
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
