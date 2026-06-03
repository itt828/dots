import QtQuick
import Quickshell.Services.Pipewire

QtObject {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    
    // Track objects to ensure properties are updated instantly
    property var tracker: PwObjectTracker {
        objects: {
            let objs = []
            if (sink) objs.push(sink)
            if (source) objs.push(source)
            return objs
        }
    }

    readonly property real volume: (sink && sink.audio && !isNaN(sink.audio.volume)) ? sink.audio.volume : 0
    readonly property bool muted: (sink && sink.audio) ? sink.audio.muted : true

    readonly property real sourceVolume: (source && source.audio && !isNaN(source.audio.volume)) ? source.audio.volume : 0
    readonly property bool sourceMuted: (source && source.audio) ? source.audio.muted : true

    function setVolume(value) {
        if (sink && sink.audio) {
            sink.audio.volume = Math.max(0, Math.min(1, value))
        }
    }

    function toggleMute() {
        if (sink && sink.audio) {
            sink.audio.muted = !sink.audio.muted
        }
    }

    function setSourceVolume(value) {
        if (source && source.audio) {
            source.audio.volume = Math.max(0, Math.min(1, value))
        }
    }

    function toggleSourceMute() {
        if (source && source.audio) {
            source.audio.muted = !source.audio.muted
        }
    }
}
