import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property real brightness: 0.0

    function update() {
        updateProc.running = true;
    }

    readonly property Process updateProc: Process {
        command: ["brightnessctl", "-m", "i"]
        stdout: StdioCollector {
            onStreamFinished: {
                // Output format: intel_backlight,backlight,2910,15%,19393
                var parts = text.split(",");
                if (parts.length >= 5) {
                    var current = parseInt(parts[2]);
                    var max = parseInt(parts[4]);
                    if (!isNaN(current) && !isNaN(max) && max !== 0) {
                        root.brightness = current / max;
                    }
                }
            }
        }
    }

    readonly property Process monitorProc: Process {
        command: ["udevadm", "monitor", "-s", "backlight"]
        running: true
        stdout: SplitParser {
            onRead: function (line) {
                if (line.includes("change")) {
                    root.update();
                }
            }
        }
    }

    Component.onCompleted: update()
}
