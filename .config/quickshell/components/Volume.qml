import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "UI"

Item {
    width: display.width
    height: display.height
    implicitWidth: display.implicitWidth
    implicitHeight: display.implicitHeight
    
    property var sink: Pipewire.defaultAudioSink
    
    BarValue {
        id: display
        value: sink ? sink.volume : 0
        showLabel: true
        labelText: sink ? Math.round(sink.volume * 100) + "%" : "--%"
        
        iconName: {
            if (!sink || sink.muted) return FontIcons.volumeMuted
            if (sink.volume > 0.6) return FontIcons.volumeHigh
            if (sink.volume > 0.3) return FontIcons.volumeMedium
            return FontIcons.volumeLow
        }
        
        progressColor: "black"
        trackColor: "#aaaaaa"
    }
}