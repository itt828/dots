pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property real usage: 0.0
    property string label: "-"

    readonly property BackendProcess _memProc: BackendProcess {
        arguments: ["metrics", "memory"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!text.trim()) return;
                try {
                    const state = JSON.parse(text);
                    root.usage = state.usage;
                    root.label = state.label;
                } catch (error) {
                    console.warn("Invalid backend metric:", error);
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
