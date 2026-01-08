import QtQuick
import Quickshell.Services.Pipewire
import "UI"

Item {
    width: display.width
    height: display.height
    implicitWidth: display.implicitWidth
    implicitHeight: display.implicitHeight

    property var sink: Pipewire.defaultAudioSink
    
    // Track the sink object to ensure properties are updated instantly
    PwObjectTracker {
        objects: sink ? [sink] : []
    }

    property real currentVolume: (sink && sink.audio && !isNaN(sink.audio.volume)) ? sink.audio.volume : 0
    property bool isMuted: (sink && sink.audio) ? sink.audio.muted : true

    BarValue {
        id: display
        value: currentVolume
        showLabel: true
        labelText: Math.round(currentVolume * 100) + "%"

        iconName: {
            if (isMuted) return FontIcons.volumeMuted
            if (currentVolume > 0.45) return FontIcons.volumeHigh
            if (currentVolume > 0.0) return FontIcons.volumeMedium
            return FontIcons.volumeLow
        }

        progressColor: "black"
        trackColor: "#aaaaaa"
    }
}
