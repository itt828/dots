pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property var modes: ({})
    readonly property var screens: Quickshell.screens
    onScreensChanged: refresh()

    function refresh(): void {
        if (!outputs.running)
            outputs.running = true;
    }

    function name(screen: var): string {
        if (!screen)
            return "";
        const builtIn = /^(eDP|LVDS|DSI)[-0-9]/i.test(screen.name);
        return (builtIn ? "内蔵ディスプレイ" : "外部ディスプレイ") + " · " + screen.name;
    }

    function resolution(screen: var): string {
        if (!screen)
            return "";
        const output = modes[screen.name];
        const mode = output?.modes?.[output.current_mode];
        const scale = screen.devicePixelRatio || 1;
        const width = mode?.width ?? Math.round(screen.width * scale);
        const height = mode?.height ?? Math.round(screen.height * scale);
        return width + " × " + height;
    }

    function label(screen: var): string {
        return name(screen) + " · " + resolution(screen);
    }

    readonly property BackendProcess outputs: BackendProcess {
        running: true
        arguments: ["niri", "outputs"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.modes = JSON.parse(text);
                } catch (_) {
                    root.modes = {};
                }
            }
        }
    }
}
