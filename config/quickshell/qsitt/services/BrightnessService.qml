pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property real brightness: 0.0
    property bool initialized: false

    function update() {
        updateProc.running = true;
    }

    readonly property BackendProcess updateProc: BackendProcess {
        arguments: ["backlight", "get", "display"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!text.trim()) return;
                try {
                    const state = JSON.parse(text);
                    root.brightness = state.brightness;
                    root.initialized = true;
                } catch (error) {
                    console.warn("Invalid backend brightness:", error);
                }
            }
        }
    }

    readonly property BackendProcess monitorProc: BackendProcess {
        arguments: ["backlight", "watch"]
        running: true
        onExited: restartMonitor.restart()
        stdout: SplitParser {
            onRead: function (line) {
                if (line.includes("change")) {
                    root.update();
                }
            }
        }
    }

    readonly property Timer restartMonitor: Timer {
        interval: 1000
        onTriggered: {
            root.update();
            root.monitorProc.running = true;
        }
    }

    Component.onCompleted: update()
}
