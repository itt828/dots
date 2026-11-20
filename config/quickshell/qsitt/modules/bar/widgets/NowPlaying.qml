pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.ui.theme
import qs.ui.widgets
import qs.services

Rectangle {
    id: root

    required property string outputName
    required property int availableWidth
    readonly property var player: MediaService.barPlayer
    readonly property bool playing: player?.playbackState === MprisPlaybackState.Playing

    readonly property bool presenting: SettingsService.barMedia && player !== null && availableWidth >= 152
    readonly property int fullWidth: Math.max(152, Math.min(316, availableWidth))
    readonly property string trackTitle: player?.trackTitle ?? ""
    readonly property string trackArtist: player?.trackArtist ?? ""
    readonly property url trackArt: player?.trackArtUrl ?? ""
    property string displayedTitle: ""
    property string displayedArtist: ""
    property url displayedArt: ""
    property real reveal: 0
    property real trackReveal: 1

    visible: presenting || reveal > 0
    implicitWidth: Math.round(fullWidth * Math.max(0, Math.min(1, reveal)))
    implicitHeight: 38
    radius: 10
    color: Theme.bgTertiary
    clip: true
    opacity: Math.max(0, Math.min(1, reveal))
    transform: Translate {
        y: (1 - root.reveal) * -6
    }

    function updateTrack(): void {
        if (!trackTitle)
            return;
        if (Theme.motionEnabled && reveal >= 0.95 && displayedTitle && (displayedTitle !== trackTitle || displayedArtist !== trackArtist)) {
            trackMotion.stop();
            trackReveal = 0;
            trackMotion.start();
        }
        displayedTitle = trackTitle;
        displayedArtist = trackArtist;
        displayedArt = trackArt;
    }

    function updateReveal(): void {
        const end = presenting ? 1 : 0;
        capsuleMotion.stop();
        if (!Theme.motionEnabled || reveal === end) {
            reveal = end;
            return;
        }

        capsuleMotion.from = reveal;
        capsuleMotion.to = end;
        capsuleMotion.duration = presenting ? Theme.motionEnter : Theme.motionExit;
        capsuleMotion.easing.type = presenting ? Easing.OutCubic : Easing.InCubic;
        capsuleMotion.start();
    }

    Component.onCompleted: {
        updateTrack();
        updateReveal();
    }
    onPresentingChanged: updateReveal()
    onTrackTitleChanged: Qt.callLater(updateTrack)
    onTrackArtistChanged: Qt.callLater(updateTrack)
    onTrackArtChanged: Qt.callLater(updateTrack)

    Connections {
        target: Theme
        function onMotionEnabledChanged(): void {
            if (!Theme.motionEnabled) {
                root.updateReveal();
                trackMotion.stop();
                root.trackReveal = 1;
            }
        }
    }

    QsNumberAnimation {
        id: capsuleMotion
        target: root
        property: "reveal"
    }

    QsNumberAnimation {
        id: trackMotion
        target: root
        property: "trackReveal"
        to: 1
        duration: Theme.motionNormal
    }

    RowLayout {
        anchors.centerIn: parent
        width: root.fullWidth - 10
        height: parent.height
        spacing: 2

        Item {
            id: track
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 0
            activeFocusOnTab: root.presenting
            Accessible.role: Accessible.Button
            Accessible.name: "再生中 " + (root.player?.trackTitle ?? "")
            Accessible.onPressAction: open()
            Keys.onReturnPressed: open()
            Keys.onSpacePressed: open()

            function open(): void {
                if (!root.presenting || !root.player)
                    return;
                MediaService.selectedBus = root.player.dbusName;
                ControlCenterService.openPage(4, root.outputName);
            }

            RowLayout {
                anchors.fill: parent
                spacing: 8
                opacity: 0.35 + 0.65 * root.trackReveal
                transform: Translate {
                    y: (1 - root.trackReveal) * 6
                }

                Rectangle {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    radius: 6
                    color: Theme.mustard200
                    clip: true

                    Image {
                        id: art
                        anchors.fill: parent
                        source: root.displayedArt
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }
                    QsIcon {
                        anchors.centerIn: parent
                        icon: Icons.mediaMusic
                        size: 16
                        color: Theme.mustard800
                        visible: art.status !== Image.Ready
                    }
                }

                QsMarqueeText {
                    Layout.fillWidth: true
                    text: root.displayedTitle + (root.displayedArtist ? " · " + root.displayedArtist : "")
                    color: Theme.ink
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.DemiBold
                    textFormat: Text.PlainText
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: track.open()
            }
        }

        QsButton {
            icon: Icons.mediaPrev
            toolTip: "前の曲"
            variant: QsButton.Ghost
            implicitWidth: 27
            implicitHeight: 29
            enabled: root.player?.canGoPrevious ?? false
            onClicked: root.player?.previous()
        }
        QsButton {
            icon: root.playing ? Icons.mediaPause : Icons.mediaPlay
            toolTip: root.playing ? "一時停止" : "再生"
            variant: QsButton.Ghost
            implicitWidth: 27
            implicitHeight: 29
            enabled: MediaService.canChangePlayback(root.player)
            onClicked: MediaService.togglePlayback(root.player)
        }
        QsButton {
            icon: Icons.mediaNext
            toolTip: "次の曲"
            variant: QsButton.Ghost
            implicitWidth: 27
            implicitHeight: 29
            enabled: root.player?.canGoNext ?? false
            onClicked: root.player?.next()
        }
    }
}
