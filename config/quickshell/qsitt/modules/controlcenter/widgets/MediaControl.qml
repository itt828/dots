pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.services
import qs.ui.widgets
import qs.ui.theme

QsPanelCard {
    id: root

    readonly property var players: MediaService.players
    readonly property var player: MediaService.player
    property bool compact: false
    readonly property bool playing: player?.playbackState === MprisPlaybackState.Playing

    padding: compact ? 10 : 16
    spacing: 5

    function duration(seconds: real): string {
        const elapsed = Math.max(0, Math.floor(seconds || 0));
        return Math.floor(elapsed / 60) + ":" + (elapsed % 60).toString().padStart(2, "0");
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Rectangle {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 44
            radius: 8
            color: Theme.mustard200
            clip: true
            Image {
                id: art
                anchors.fill: parent
                source: root.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
            QsIcon {
                anchors.centerIn: parent
                icon: Icons.mediaMusic
                size: 21
                color: Theme.mustard800
                visible: art.status !== Image.Ready
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            spacing: 1
            QsMarqueeText {
                Layout.fillWidth: true
                text: root.player?.trackTitle || "タイトルなし"
                textFormat: Text.PlainText
                color: Theme.ink
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeBody
                font.weight: Font.Bold
            }
            QsMarqueeText {
                Layout.fillWidth: true
                text: [root.player?.trackArtist || root.player?.identity, VolumeService.sink ? VolumeService.sinkName : ""].filter(value => value).join(" · ")
                textFormat: Text.PlainText
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        QsButton {
            visible: root.players.length > 1
            icon: Icons.mediaMusic
            toolTip: "プレーヤーを切り替え"
            implicitWidth: 30
            implicitHeight: 30
            variant: QsButton.Ghost
            onClicked: MediaService.selectNext()
        }
        QsButton {
            icon: Icons.mediaPrev
            toolTip: "前の曲"
            variant: QsButton.Ghost
            implicitWidth: 30
            implicitHeight: 30
            enabled: root.player?.canGoPrevious ?? false
            onClicked: root.player?.previous()
        }
        QsButton {
            icon: root.playing ? Icons.mediaPause : Icons.mediaPlay
            toolTip: root.playing ? "一時停止" : "再生"
            variant: QsButton.Primary
            implicitWidth: 30
            implicitHeight: 30
            enabled: MediaService.canChangePlayback(root.player)
            onClicked: MediaService.togglePlayback(root.player)
        }
        QsButton {
            icon: Icons.mediaNext
            toolTip: "次の曲"
            variant: QsButton.Ghost
            implicitWidth: 30
            implicitHeight: 30
            enabled: root.player?.canGoNext ?? false
            onClicked: root.player?.next()
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: (root.player?.lengthSupported ?? false) && (root.player?.positionSupported ?? false)
        spacing: 6

        QsSectionLabel {
            text: root.duration(root.player?.position ?? 0)
        }
        QsSlider {
            Layout.fillWidth: true
            implicitHeight: 18
            Accessible.name: "再生位置"
            to: root.player?.length > 0 ? root.player.length : 1
            value: root.player?.position ?? 0
            enabled: root.player?.canSeek ?? false
            onMoved: value => {
                if (root.player?.canSeek)
                    root.player.position = value;
            }
        }
        QsSectionLabel {
            text: root.duration(root.player?.length ?? 0)
        }
    }

    Timer {
        interval: 1000
        running: root.visible && root.playing
        repeat: true
        onTriggered: root.player?.positionChanged()
    }
}
