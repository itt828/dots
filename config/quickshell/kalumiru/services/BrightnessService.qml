pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property real brightness: 0.0
    property bool initialized: false
    property int requestedPercent: -1
    readonly property real displayBrightness: requestedPercent < 0 ? brightness : requestedPercent / 100

    function setBrightness(value: real): void {
        if (!initialized || !Number.isFinite(value))
            return;
        const percent = Math.round(Math.max(0, Math.min(1, value)) * 100);
        if (percent === requestedPercent || (requestedPercent < 0 && percent === Math.round(brightness * 100)))
            return;
        requestedPercent = percent;
        if (!setProc.running)
            setProc.applyRequest();
    }

    function readBrightness(text: string): void {
        if (!text.trim())
            return;
        try {
            const state = JSON.parse(text);
            brightness = state.brightness;
            initialized = true;
        } catch (error) {
            console.warn("Invalid backend brightness:", error);
        }
    }

    function update() {
        updateProc.running = true;
    }

    readonly property BackendProcess updateProc: BackendProcess {
        arguments: ["backlight", "get", "display"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.requestedPercent < 0)
                    root.readBrightness(text);
            }
        }
    }

    readonly property BackendProcess setProc: BackendProcess {
        property int writingPercent: -1

        function applyRequest(): void {
            writingPercent = root.requestedPercent;
            execute(["backlight", "display-set", String(writingPercent)]);
        }

        stdout: StdioCollector {
            onStreamFinished: root.readBrightness(text)
        }
        onExited: exitCode => {
            if (root.requestedPercent !== writingPercent) {
                applyRequest();
                return;
            }
            root.requestedPercent = -1;
            if (exitCode !== 0)
                root.update();
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
