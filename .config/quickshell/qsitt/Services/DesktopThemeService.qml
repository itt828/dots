pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.Theme

QtObject {
    id: root

    property string _runningScheme: ""
    property string _queuedScheme: ""

    function schemeForMode(mode: string): string {
        return mode === "dark" ? "prefer-dark" : "prefer-light";
    }

    function sync(): void {
        const scheme = schemeForMode(Theme.currentMode);
        if (_syncProcess.running) {
            _queuedScheme = scheme;
            return;
        }

        _runningScheme = scheme;
        _queuedScheme = "";
        _syncProcess.command = [
            "gsettings", "set", "org.gnome.desktop.interface", "color-scheme", scheme
        ];
        _syncProcess.running = true;
    }

    readonly property Connections themeConnection: Connections {
        target: Theme

        function onCurrentModeChanged(): void {
            root.sync();
        }
    }

    readonly property Process _syncProcess: Process {
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                console.warn("Failed to synchronize desktop color scheme:", root._runningScheme);

            const queuedScheme = root._queuedScheme;
            root._queuedScheme = "";
            if (queuedScheme !== "" && queuedScheme !== root._runningScheme)
                root.sync();
        }
    }
}
