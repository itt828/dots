pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    readonly property var availablePalettes: detectedPalettes.map(name => ({
                "name": name,
                "label": paletteLabel(name)
            }))
    readonly property var availableModes: ["light", "dark", "auto"]

    readonly property var fallbackPalette: ({
            "light": {
                "bg-primary": "#fcfaf6",
                "bg-secondary": "#ffffff",
                "bg-tertiary": "#f6f3ec",
                "text-primary": "#24211c",
                "text-secondary": "#615d54",
                "border-primary": "#e8e4dd",
                "accent": "#e3cfa5",
                "success": "#258343",
                "warn": "#9a5f1a",
                "status/error": "#ba3e3c",
                "info": "#346fb8",
                "surface": "#fcfaf6",
                "ink": "#252a32",
                "muted": "#626975",
                "border": "#b3b9c2",
                "subtle": "#f5f6f8",
                "hover": "#eceef1",
                "pressed": "#dce0e5",
                "focus": "#8b5b25",
                "disabled": "#e7e9ed",
                "disabled-ink": "#747b86",
                "accent-hover": "#dcab72",
                "accent-pressed": "#cc985d",
                "error": "#af303a",
                "error-hover": "#982832",
                "error-pressed": "#7d2029",
                "error-surface": "#fff3f3",
                "mustard/50": "#faf5e6",
                "mustard/200": "#f1dfa7",
                "mustard/500": "#b99a43",
                "mustard/800": "#725a19",
                "canvas/warm": "#e9e4da",
                "shadow": "#1f332914"
            },
            "dark": {
                "bg-primary": "#16130b",
                "bg-secondary": "#231f17",
                "bg-tertiary": "#231f17",
                "text-primary": "#eae1d4",
                "text-secondary": "#cfc5b4",
                "border-primary": "#4c4639",
                "accent": "#785e26",
                "success": "#aecfac",
                "warn": "#ffc780",
                "status/error": "#ffb4ab",
                "info": "#a6c8ff",
                "surface": "#16130b",
                "ink": "#eae1d4",
                "muted": "#cfc5b4",
                "border": "#989080",
                "subtle": "#2e2921",
                "hover": "#393329",
                "pressed": "#4c4639",
                "focus": "#edca78",
                "disabled": "#332e24",
                "disabled-ink": "#ada392",
                "accent-hover": "#876c30",
                "accent-pressed": "#956f31",
                "error": "#ffb4ab",
                "error-hover": "#ff9b90",
                "error-pressed": "#ff8579",
                "error-surface": "#461d1b",
                "mustard/50": "#211c10",
                "mustard/200": "#594400",
                "mustard/500": "#b99a43",
                "mustard/800": "#e5c36c",
                "canvas/warm": "#1f1b13",
                "shadow": "#60000000"
            }
        })

    readonly property var legacyColorKeys: ({
            "bg-primary": "background",
            "bg-secondary": "surface",
            "bg-tertiary": "surfaceContainer",
            "text-primary": "text",
            "text-secondary": "textSecondary",
            "border-primary": "outlineVariant",
            "status/error": "danger",
            "ink": "text",
            "muted": "textSecondary",
            "border": "outline",
            "subtle": "surfaceContainer",
            "hover": "surfaceContainerHigh",
            "pressed": "surfaceVariant",
            "focus": "primary",
            "disabled": "surfaceVariant",
            "disabled-ink": "textSecondary",
            "accent-hover": "primaryContainer",
            "accent-pressed": "primaryContainer",
            "error": "danger",
            "error-hover": "danger",
            "error-pressed": "danger",
            "mustard/50": "surfaceContainerLow",
            "mustard/200": "primaryContainer",
            "mustard/500": "accent",
            "mustard/800": "primary",
            "canvas/warm": "background"
        })

    property string configuredPalette: "qsitt"
    property string configuredMode: "light"
    property var detectedPalettes: ["qsitt"]
    property var paletteData: fallbackPalette
    property bool loaded: false
    property bool paletteLoadFinished: false
    property bool modeLoadFinished: false
    property bool paletteTouched: false
    property bool modeTouched: false
    property string savedPalette: ""
    property string savedMode: ""

    readonly property string currentPalette: hasPalette(configuredPalette) ? configuredPalette : (detectedPalettes.length > 0 ? detectedPalettes[0] : "qsitt")
    readonly property SystemClock clock: SystemClock {
        precision: SystemClock.Minutes
    }
    readonly property string currentMode: configuredMode === "auto" ? (clock.date.getHours() >= 18 || clock.date.getHours() < 6 ? "dark" : "light") : configuredMode === "dark" ? "dark" : "light"
    readonly property string currentName: currentPalette + "-" + currentMode
    readonly property var current: paletteData[currentMode] ?? fallbackPalette[currentMode]

    readonly property FolderListModel paletteDirectory: FolderListModel {
        folder: Qt.resolvedUrl("../config/palettes")
        nameFilters: ["*.toml"]
        showDirs: false
        showDotAndDotDot: false
        sortField: FolderListModel.Name

        onCountChanged: root.refreshPalettes()
        onStatusChanged: {
            if (status === FolderListModel.Ready)
                root.refreshPalettes();
        }
    }

    readonly property FileView paletteFile: FileView {
        path: Quickshell.shellPath("config/palettes/" + root.currentPalette + ".toml")
        blockLoading: true
        watchChanges: true

        onLoaded: root.loadPalette(text())
        onFileChanged: paletteReloadTimer.restart()
        onLoadFailed: error => {
            root.paletteData = root.fallbackPalette;
            console.warn("Failed to load palette:", path, error);
        }
    }

    readonly property Timer paletteReloadTimer: Timer {
        interval: 50
        onTriggered: root.paletteFile.reload()
    }

    Component.onCompleted: {
        finishLoad();
        paletteFile.reload();
    }

    onCurrentPaletteChanged: paletteFile.reload()

    function hasPalette(name: string): bool {
        return detectedPalettes.includes(name);
    }

    function paletteLabel(name: string): string {
        return name.split(/[-_]/).map(part => part.length === 0 ? "" : part[0].toUpperCase() + part.slice(1)).join(" ");
    }

    function refreshPalettes(): void {
        const names = [];
        for (let index = 0; index < paletteDirectory.count; index++) {
            const fileName = paletteDirectory.get(index, "fileName");
            const name = fileName.endsWith(".toml") ? fileName.slice(0, -5).toLowerCase() : "";
            if (/^[a-z0-9][a-z0-9_-]*$/.test(name) && !names.includes(name))
                names.push(name);
        }
        if (names.length > 0)
            detectedPalettes = names;
    }

    function tomlValue(value: string): string {
        const commentless = stripTomlComment(value).trim();
        if (commentless.length >= 2) {
            const first = commentless[0];
            const last = commentless[commentless.length - 1];
            if ((first === "\"" && last === "\"") || (first === "'" && last === "'"))
                return commentless.slice(1, -1);
        }
        return commentless;
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

    function legacySelection(content: string): var {
        let section = "";
        let palette = "qsitt";
        let mode = "light";
        for (const rawLine of content.split(/\r?\n/)) {
            const line = stripTomlComment(rawLine).trim();
            const sectionMatch = line.match(/^\[([^\]]+)\]$/);
            if (sectionMatch) {
                section = sectionMatch[1].trim();
                continue;
            }
            if (section !== "theme" || line === "")
                continue;
            const assignment = line.match(/^([A-Za-z0-9_-]+)\s*=\s*(.+)$/);
            if (!assignment)
                continue;
            if (assignment[1] === "palette")
                palette = tomlValue(assignment[2]);
            else if (assignment[1] === "mode")
                mode = tomlValue(assignment[2]);
        }
        return {
            palette: palette.trim().toLowerCase(),
            mode: mode.trim().toLowerCase()
        };
    }

    function loadPalette(content: string): void {
        const parsed = {
            "light": {},
            "dark": {}
        };
        let section = "";

        for (const rawLine of content.split(/\r?\n/)) {
            const line = stripTomlComment(rawLine).trim();
            const sectionMatch = line.match(/^\[([^\]]+)\]$/);
            if (sectionMatch) {
                section = sectionMatch[1].trim();
                continue;
            }
            if ((section !== "light" && section !== "dark") || line === "")
                continue;
            const assignment = line.match(/^(?:"([a-zA-Z0-9_/-]+)"|'([a-zA-Z0-9_/-]+)'|([a-zA-Z0-9_-]+))\s*=\s*(.+)$/);
            if (!assignment)
                continue;
            const key = assignment[1] ?? assignment[2] ?? assignment[3];
            const value = tomlValue(assignment[4]);
            if (/^#(?:[0-9a-f]{3}|[0-9a-f]{6}|[0-9a-f]{8})$/i.test(value))
                parsed[section][key] = value;
        }

        paletteData = {
            "light": resolveColors("light", parsed.light),
            "dark": resolveColors("dark", parsed.dark)
        };
    }

    function resolveColors(mode: string, colors: var): var {
        const defaults = fallbackPalette[mode];
        const resolved = {};
        for (const key of Object.keys(defaults)) {
            const oldKey = legacyColorKeys[key];
            resolved[key] = colors[key] ?? (oldKey ? colors[oldKey] : undefined) ?? defaults[key];
        }
        return resolved;
    }

    function finishLoad(): void {
        if (loaded || !paletteLoadFinished || !modeLoadFinished || !LegacyConfig.ready)
            return;
        const legacy = legacySelection(LegacyConfig.content);
        const palette = savedPalette !== "" ? savedPalette : legacy.palette;
        const mode = savedMode !== "" ? savedMode : legacy.mode;
        if (!paletteTouched)
            configuredPalette = /^[a-z0-9][a-z0-9_-]*$/.test(palette) ? palette : "qsitt";
        if (!modeTouched)
            configuredMode = availableModes.includes(mode) ? mode : "light";
        loaded = true;
    }

    readonly property Connections legacyConnection: Connections {
        target: LegacyConfig
        function onReadyChanged(): void {
            root.finishLoad();
        }
    }

    readonly property BackendProcess paletteLoader: BackendProcess {
        running: true
        arguments: ["state", "load", "theme"]
        stdout: StdioCollector {
            onStreamFinished: root.savedPalette = text.trim()
        }
        onExited: {
            root.paletteLoadFinished = true;
            root.finishLoad();
        }
    }

    readonly property BackendProcess modeLoader: BackendProcess {
        running: true
        arguments: ["state", "load", "mode"]
        stdout: StdioCollector {
            onStreamFinished: root.savedMode = text.trim()
        }
        onExited: {
            root.modeLoadFinished = true;
            root.finishLoad();
        }
    }

    readonly property BackendProcess paletteSaver: BackendProcess {
        property string pending: ""
        function save(name: string): void {
            if (running) {
                pending = name;
                return;
            }
            pending = "";
            execute(["state", "save", "theme", name]);
        }
        onExited: {
            if (pending !== "") {
                const next = pending;
                pending = "";
                execute(["state", "save", "theme", next]);
            }
        }
    }

    readonly property BackendProcess modeSaver: BackendProcess {
        property string pending: ""
        function save(name: string): void {
            if (running) {
                pending = name;
                return;
            }
            pending = "";
            execute(["state", "save", "mode", name]);
        }
        onExited: {
            if (pending !== "") {
                const next = pending;
                pending = "";
                execute(["state", "save", "mode", next]);
            }
        }
    }

    function setPalette(name: string): bool {
        const normalizedName = name.trim().toLowerCase();
        if (!hasPalette(normalizedName))
            return false;
        paletteTouched = true;
        configuredPalette = normalizedName;
        paletteSaver.save(normalizedName);
        return true;
    }

    function setMode(mode: string): bool {
        const normalizedMode = mode.trim().toLowerCase();
        if (!availableModes.includes(normalizedMode))
            return false;
        modeTouched = true;
        configuredMode = normalizedMode;
        modeSaver.save(normalizedMode);
        return true;
    }

    function setTheme(name: string): bool {
        return setPalette(name);
    }

    function toggleTheme(): string {
        const nextMode = currentMode === "dark" ? "light" : "dark";
        setMode(nextMode);
        return nextMode;
    }
}
