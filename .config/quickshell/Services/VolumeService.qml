import QtQuick
import Quickshell.Services.Pipewire
import Quickshell.Io

QtObject {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    // Track objects to ensure properties are updated instantly
    property var tracker: PwObjectTracker {
        objects: {
            let objs = [];
            if (sink)
                objs.push(sink);
            if (source)
                objs.push(source);
            return objs;
        }
    }

    readonly property real volume: (sink && sink.audio && !isNaN(sink.audio.volume)) ? sink.audio.volume : 0
    readonly property bool muted: (sink && sink.audio) ? sink.audio.muted : true
    readonly property string sinkName: sink ? (sink.description || sink.name || "Unknown Sink") : "No Sink"

    readonly property real sourceVolume: (source && source.audio && !isNaN(source.audio.volume)) ? source.audio.volume : 0
    readonly property bool sourceMuted: (source && source.audio) ? source.audio.muted : true
    readonly property string sourceName: source ? (source.description || source.name || "Unknown Source") : "No Source"

    function setVolume(value) {
        if (sink && sink.audio) {
            sink.audio.volume = Math.max(0, Math.min(1, value));
        }
    }

    function toggleMute() {
        if (sink && sink.audio) {
            sink.audio.muted = !sink.audio.muted;
        }
    }

    function setSourceVolume(value) {
        if (source && source.audio) {
            source.audio.volume = Math.max(0, Math.min(1, value));
        }
    }

    function toggleSourceMute() {
        if (source && source.audio) {
            source.audio.muted = !source.audio.muted;
        }
    }

    property string alsaCardName: ""
    property string activeProfile: ""
    property string headphoneProfile: ""
    property string speakerProfile: ""

    readonly property bool isHeadphones: activeProfile.includes("Headphones")
    readonly property bool isSpeaker: activeProfile.includes("Speaker")

    property Process getProfileProc: Process {
        command: ["pactl", "-f", "json", "list", "cards"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let cards = JSON.parse(text);
                    let alsaCard = cards.find(card => card.name && card.name.startsWith("alsa_card."));
                    if (alsaCard) {
                        root.alsaCardName = alsaCard.name;
                        root.activeProfile = alsaCard.active_profile;

                        let profiles = Object.keys(alsaCard.profiles || {});
                        root.headphoneProfile = profiles.find(p => p.includes("Headphones")) || "";
                        root.speakerProfile = profiles.find(p => p.includes("Speaker")) || "";
                    }
                } catch (e) {
                    console.log("Error parsing pactl cards:", e);
                }
            }
        }
    }

    function refreshProfile() {
        getProfileProc.running = true;
    }

    property Process setProfileProc: Process {
        onRunningChanged: {
            if (!running) {
                root.refreshProfile();
            }
        }
    }

    function toggleProfile() {
        if (!alsaCardName)
            return;
        let newProfile = "";
        if (isHeadphones) {
            newProfile = speakerProfile;
        } else {
            newProfile = headphoneProfile;
        }
        if (!newProfile)
            return;
        setProfileProc.command = ["pactl", "set-card-profile", root.alsaCardName, newProfile];
        setProfileProc.running = true;
    }

    Component.onCompleted: {
        refreshProfile();
    }
}
