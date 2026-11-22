pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.modules.bar.widgets as BarUi
import qs.modules.controlcenter.widgets as CenterUi
import qs.ui.widgets

QsPanelCard {
    id: root

    required property bool previewActive
    property bool narrowCapsule: false
    property bool showControl: true

    padding: 14
    spacing: 12

    component PreviewTrack: QtObject {
        required property string title
        property string artist: ""
        required property real length
    }

    QtObject {
        id: demo

        readonly property var players: [demoPlayer]
        readonly property var player: demoPlayer
    }

    QtObject {
        id: demoPlayer

        readonly property string dbusName: "demo"
        readonly property string identity: "サンプルプレーヤー"
        readonly property url trackArtUrl: ""
        property list<PreviewTrack> tracks: [
            PreviewTrack {
                title: "朝の散歩"
                artist: "サンプルアーティスト"
                length: 192
            },
            PreviewTrack {
                title: "窓辺で聴く、長いタイトルのプレイリスト"
                artist: "Studio Sample"
                length: 247
            },
            PreviewTrack {
                title: "Instrumental"
                length: 156
            }
        ]
        property int trackIndex: 0
        property int playbackState: MprisPlaybackState.Paused
        property real position: 32
        readonly property PreviewTrack track: tracks[trackIndex]
        readonly property string trackTitle: track.title
        readonly property string trackArtist: track.artist
        readonly property real length: track.length
        readonly property bool lengthSupported: true
        readonly property bool positionSupported: true
        readonly property bool canSeek: true
        readonly property bool canPlay: true
        readonly property bool canPause: true
        readonly property bool canGoPrevious: trackIndex > 0
        readonly property bool canGoNext: trackIndex < tracks.length - 1

        function play(): void {
            if (position >= length)
                position = 0;
            playbackState = MprisPlaybackState.Playing;
        }

        function pause(): void {
            playbackState = MprisPlaybackState.Paused;
        }

        function previous(): void {
            if (canGoPrevious) {
                trackIndex--;
                position = 0;
            }
        }

        function next(): void {
            if (canGoNext) {
                trackIndex++;
                position = 0;
            }
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.previewActive && root.visible && demoPlayer.playbackState === MprisPlaybackState.Playing
        onTriggered: {
            demoPlayer.position = Math.min(demoPlayer.position + 1, demoPlayer.length);
            if (demoPlayer.position >= demoPlayer.length) {
                if (demoPlayer.canGoNext)
                    demoPlayer.next();
                else
                    demoPlayer.pause();
            }
        }
    }

    QsSectionLabel {
        text: "NowPlaying"
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: capsule.implicitHeight

        BarUi.NowPlaying {
            id: capsule

            player: demoPlayer.trackTitle ? demoPlayer : null
            mediaEnabled: true
            availableWidth: Math.floor(Math.min(parent.width, root.narrowCapsule ? 152 : 316))
            onTrackActivated: root.showControl = true
        }
    }

    Flow {
        Layout.fillWidth: true
        spacing: 8

        QsButton {
            text: "バーを最小幅に"
            checkable: true
            highlighted: root.narrowCapsule
            onClicked: root.narrowCapsule = !root.narrowCapsule
        }

        QsButton {
            text: "再生コントロール"
            checkable: true
            highlighted: root.showControl
            onClicked: root.showControl = !root.showControl
        }
    }

    CenterUi.MediaControl {
        visible: root.showControl
        mediaService: demo
        outputLabel: "ダミー出力"
        compact: true
    }

    StoryTextField {
        label: "曲名"
        text: demoPlayer.trackTitle
        onTextEdited: value => demoPlayer.track.title = value
    }

    StoryTextField {
        label: "アーティスト名"
        text: demoPlayer.trackArtist
        onTextEdited: value => demoPlayer.track.artist = value
    }
}
