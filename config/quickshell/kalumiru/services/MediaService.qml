pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.Mpris

QtObject {
    id: root

    readonly property var players: Mpris.players.values
    property string selectedBus: ""
    property string lastPlayingBus: ""
    readonly property var playing: players.find(player => player.playbackState === MprisPlaybackState.Playing && player.trackTitle) ?? null
    readonly property var barPlayer: playing ?? players.find(player => player.dbusName === lastPlayingBus && isPausedTrack(player)) ?? players.find(isPausedTrack) ?? null
    readonly property var player: players.find(player => player.dbusName === selectedBus) ?? playing ?? players[0] ?? null

    onPlayingChanged: if (playing)
        lastPlayingBus = playing.dbusName

    function isPausedTrack(target: var): bool {
        return !!target.trackTitle && target.playbackState === MprisPlaybackState.Paused;
    }

    function canChangePlayback(target: var): bool {
        return !!target && (target.playbackState === MprisPlaybackState.Playing ? target.canPause : target.canPlay);
    }

    function togglePlayback(target: var): void {
        if (!canChangePlayback(target))
            return;
        if (target.playbackState === MprisPlaybackState.Playing)
            target.pause();
        else
            target.play();
    }

    function selectNext(): void {
        if (players.length > 1)
            selectedBus = players[(players.indexOf(player) + 1) % players.length].dbusName;
    }
}
