import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property real usage: 0.0
    property string label: "-"

    readonly property Process _memProc: Process {
        command: ["sh", "-c", "free | grep Mem"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text) {
                    // Output format: Mem: total used free shared buff/cache available
                    var parts = text.trim().split(/\s+/)
                    if (parts.length >= 7) {
                        var total = parseInt(parts[1])
                        var used = parseInt(parts[2])
                        if (!isNaN(total) && !isNaN(used) && total !== 0) {
                            root.usage = used / total
                            root.label = Math.round(root.usage * 100) + "%"
                        }
                    }
                }
            }
        }
    }

    readonly property Timer _timer: Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: _memProc.running = true
    }
}
