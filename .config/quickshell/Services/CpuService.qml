import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property real usage: 0.0
    property string label: "-"

    readonly property Process _loadProc: Process {
        command: ["cat", "/proc/loadavg"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text) {
                    var parts = text.trim().split(" ")
                    if (parts.length > 0) {
                        var load = parseFloat(parts[0])
                        root.label = parts[0]
                        root.usage = Math.min(load / 4.0, 1.0) // Normalizing for 4 cores as before
                    }
                }
            }
        }
    }

    readonly property Timer _timer: Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: _loadProc.running = true
    }
}
