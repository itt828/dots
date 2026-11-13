import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.ui.widgets
import qs.ui.theme

Rectangle {
    id: root
    readonly property var players: Mpris.players.values
    property int selectedPlayer: -1
    readonly property var player: selectedPlayer >= 0 && selectedPlayer < players.length ? players[selectedPlayer] : players.find(p => p.playbackState === Mpris.Playing) || players[0] || null
    color: Theme.surfaceContainer
    radius: 16
    implicitHeight: 184
    Layout.fillWidth: true
    function duration(seconds) {
        const s = Math.max(0, Math.floor(seconds || 0));
        return Math.floor(s / 60) + ":" + (s % 60).toString().padStart(2, "0");
    }
    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 18
        Rectangle {
            Layout.preferredWidth: 104
            Layout.preferredHeight: 130
            radius: 12
            color: Theme.surfaceContainerHigh
            clip: true
            Image {
                id: art
                anchors.fill: parent
                source: root.player ? root.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
            }
            QsIcon {
                anchors.centerIn: parent
                icon: Icons.mediaMusic
                size: 36
                color: Theme.primary
                visible: art.status !== Image.Ready
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6
            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: root.player ? root.player.identity : "メディア"
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
                QsButton {
                    visible: root.players.length > 1
                    text: "切替"
                    onClicked: root.selectedPlayer = (root.players.indexOf(root.player) + 1) % root.players.length
                }
            }
            Text {
                Layout.fillWidth: true
                text: root.player ? root.player.trackTitle || "タイトルなし" : "再生中のメディアはありません"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: 17
                font.bold: true
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: root.player ? root.player.trackArtist || "アーティスト不明" : "音楽や動画を再生するとここに表示されます"
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                elide: Text.ElideRight
            }
            QsProgressBar {
                Layout.fillWidth: true
                from: 0
                to: root.player && root.player.length > 0 ? root.player.length : 1
                value: root.player ? root.player.position : 0
                visible: root.player && root.player.lengthSupported
            }
            RowLayout {
                Layout.fillWidth: true
                QsButton {
                    text: "⏮"
                    enabled: root.player && root.player.canGoPrevious
                    onClicked: root.player.previous()
                }
                QsButton {
                    text: root.player && root.player.playbackState === Mpris.Playing ? "一時停止" : "再生"
                    enabled: root.player && root.player.canTogglePlaying
                    onClicked: root.player.playPause()
                }
                QsButton {
                    text: "⏭"
                    enabled: root.player && root.player.canGoNext
                    onClicked: root.player.next()
                }
                Item {
                    Layout.fillWidth: true
                }
                Text {
                    visible: root.player && root.player.lengthSupported
                    text: root.player ? root.duration(root.player.position) + " / " + root.duration(root.player.length) : ""
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                }
            }
        }
    }
    Timer {
        interval: 1000
        running: root.visible && root.player && root.player.playbackState === Mpris.Playing
        repeat: true
        onTriggered: root.player.positionChanged()
    }
}
