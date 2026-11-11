pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    readonly property var defaults: ({
        targetScreens: [],
        animationDuration: 200,
        debug: false,
        lidClamshellMode: false
    })
    property var values: ({})
    property var pendingChanges: ({})
    property bool loaded: false
    property bool loadFinished: false
    property string savedText: ""
    readonly property string script: Quickshell.shellDir + "/scripts/state/settings-state.sh"

    readonly property var targetScreens: get("targetScreens")
    readonly property int animationDuration: get("animationDuration")
    readonly property bool debug: get("debug")
    readonly property bool lidClamshellMode: get("lidClamshellMode")

    function get(key: string): var {
        return Object.prototype.hasOwnProperty.call(values, key) ? values[key] : defaults[key];
    }

    function equal(a: var, b: var): bool {
        return JSON.stringify(a) === JSON.stringify(b);
    }

    function valid(key: string, value: var): bool {
        if (key === "targetScreens")
            return Array.isArray(value) && value.every(item => typeof item === "string");
        if (key === "animationDuration")
            return typeof value === "number" && Number.isFinite(value) && value >= 0;
        if (key === "debug" || key === "lidClamshellMode")
            return typeof value === "boolean";
        return false;
    }

    function set(key: string, value: var): bool {
        if (!valid(key, value))
            return false;
        const normalized = Array.isArray(value) ? value.slice() : value;
        if (loaded && equal(get(key), normalized))
            return true;
        const next = Object.assign({}, values);
        if (equal(normalized, defaults[key]))
            delete next[key];
        else
            next[key] = normalized;
        values = next;
        if (!loaded)
            pendingChanges = Object.assign({}, pendingChanges, { [key]: normalized });
        else
            saveTimer.restart();
        return true;
    }

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
        let match;
        while ((match = expression.exec(stripTomlComment(value))) !== null)
            result.push(match[1] ?? match[2]);
        return result;
    }

    function legacyValues(content: string): var {
        let section = "";
        const imported = {};
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
            const value = stripTomlComment(assignment[2]).trim();
            if (assignment[1] === "target_screens")
                imported.targetScreens = tomlStringArray(value);
            else if (assignment[1] === "lid_clamshell_mode")
                imported.lidClamshellMode = value.toLowerCase() === "true";
            else if (assignment[1] === "animation_duration")
                imported.animationDuration = Number(value);
            else if (assignment[1] === "debug")
                imported.debug = value.toLowerCase() === "true";
        }
        return imported;
    }

    function restore(text: string): var {
        if (text.trim() === "")
            return legacyValues(LegacyConfig.content);
        try {
            const parsed = JSON.parse(text);
            return parsed && typeof parsed === "object" && !Array.isArray(parsed) ? parsed : {};
        } catch (error) {
            console.warn("Invalid settings.json; loading legacy settings:", error);
            return legacyValues(LegacyConfig.content);
        }
    }

    function finishLoad(): void {
        if (loaded || !loadFinished || !LegacyConfig.ready)
            return;
        const restored = restore(savedText);
        const next = {};
        for (const key of Object.keys(defaults)) {
            const value = Object.prototype.hasOwnProperty.call(pendingChanges, key) ? pendingChanges[key] : restored[key];
            if (valid(key, value) && !equal(value, defaults[key]))
                next[key] = value;
        }
        values = next;
        loaded = true;
        if (Object.keys(pendingChanges).length > 0 || Object.prototype.hasOwnProperty.call(restored, "lidKeepOnScreens"))
            saveTimer.restart();
        pendingChanges = {};
    }

    readonly property Connections legacyConnection: Connections {
        target: LegacyConfig
        function onReadyChanged(): void { root.finishLoad(); }
    }

    readonly property Process loader: Process {
        running: true
        command: ["sh", root.script, "load"]
        stdout: StdioCollector {
            onStreamFinished: root.savedText = text
        }
        onExited: {
            root.loadFinished = true;
            root.finishLoad();
        }
    }

    readonly property Timer saveTimer: Timer {
        interval: 250
        onTriggered: root.saver.save(JSON.stringify(root.values))
    }

    readonly property Process saver: Process {
        property string pending: ""
        function save(json: string): void {
            if (running) {
                pending = json;
                return;
            }
            pending = "";
            exec(["sh", root.script, "save", json]);
        }
        onExited: {
            if (pending !== "") {
                const next = pending;
                pending = "";
                exec(["sh", root.script, "save", next]);
            }
        }
    }
}
