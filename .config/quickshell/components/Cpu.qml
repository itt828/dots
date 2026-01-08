import QtQuick
import Quickshell
import Quickshell.Io
import "UI"

Item {
    id: root
    width: display.width
    height: display.height
    implicitWidth: display.implicitWidth
    implicitHeight: display.implicitHeight

    property real cpuVal: 0.0
    property string cpuText: "-"

    // CPU Widget
    BarValue {
        id: display
        value: root.cpuVal
        iconName: FontIcons.cpu
        showLabel: true
        labelText: root.cpuText
        progressColor: "black"
        trackColor: "#aaaaaa"
    }

    // Load Average / CPU
    Process {
        id: loadProc
        command: ["cat", "/proc/loadavg"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text) {
                    var parts = text.split(" ")
                    if (parts.length > 0) {
                        var load = parseFloat(parts[0])
                        root.cpuText = parts[0]
                        root.cpuVal = Math.min(load / 4.0, 1.0)
                    }
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            loadProc.running = true
        }
    }
}
