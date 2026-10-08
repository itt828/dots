pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    // Values are loaded from the [settings] section in config.toml.
    property var _targetScreens: []
    property int _animationDuration: 200
    property bool _debug: false

    readonly property var targetScreens: _targetScreens
    readonly property int animationDuration: _animationDuration
    readonly property bool debug: _debug

    readonly property FileView configFile: FileView {
        path: Quickshell.shellPath("config.toml")
        blockLoading: true
        watchChanges: true

        onLoaded: root.loadConfig(text())
        onFileChanged: reloadTimer.restart()
        onLoadFailed: error => console.warn("Failed to load settings from config.toml:", error)
    }

    readonly property Timer reloadTimer: Timer {
        interval: 50
        onTriggered: root.configFile.reload()
    }

    Component.onCompleted: loadConfig(configFile.text())

    function stripTomlComment(line: string): string {
        let quote = "";
        for (let index = 0; index < line.length; index++) {
            const character = line[index];
            if ((character === "\"" || character === "'") && (index === 0 || line[index - 1] !== "\\"))
                quote = quote === "" ? character : (quote === character ? "" : quote);
            else if (character === "#" && quote === "")
                return line.slice(0, index);
        }
        return line;
    }

    function tomlStringArray(value: string): var {
        const result = [];
        const expression = /"([^"]*)"|'([^']*)'/g;
        const commentless = stripTomlComment(value);
        let match;
        while ((match = expression.exec(commentless)) !== null)
            result.push(match[1] ?? match[2]);
        return result;
    }

    function loadConfig(content: string): void {
        let section = "";
        let screens = [];
        let duration = 200;
        let debugEnabled = false;

        for (const rawLine of content.split(/\r?\n/)) {
            const line = stripTomlComment(rawLine).trim();
            const sectionMatch = line.match(/^\[([^\]]+)\]$/);
            if (sectionMatch) {
                section = sectionMatch[1].trim();
                continue;
            }
            if (section !== "settings" || line === "")
                continue;

            const assignment = line.match(/^([A-Za-z0-9_-]+)\s*=\s*(.+)$/);
            if (!assignment)
                continue;
            const key = assignment[1];
            const value = stripTomlComment(assignment[2]).trim();

            if (key === "target_screens") {
                screens = tomlStringArray(value);
            } else if (key === "animation_duration") {
                const parsedDuration = Number(value);
                if (Number.isFinite(parsedDuration) && parsedDuration >= 0)
                    duration = Math.round(parsedDuration);
            } else if (key === "debug") {
                debugEnabled = value.toLowerCase() === "true";
            }
        }

        _targetScreens = screens;
        _animationDuration = duration;
        _debug = debugEnabled;
    }
}
