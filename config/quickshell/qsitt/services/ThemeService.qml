pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    // Palette files define colors; selected palette and mode live in XDG state.
    readonly property var availablePalettes: detectedPalettes.map(name => ({
        "name": name,
        "label": paletteLabel(name)
    }))
    readonly property var availableModes: ["light", "dark"]

    readonly property var fallbackPalette: ({
        "light": {
            "background": "#eef2f5", "surface": "#ffffff", "surfaceVariant": "#e8eef2",
            "surfaceContainerLow": "#eaf6fc", "surfaceContainer": "#f6f8fa", "surfaceContainerHigh": "#e1e8ed",
            "primary": "#0078d4", "primaryContainer": "#d8ebff", "primaryText": "#ffffff",
            "text": "#000000", "textSecondary": "#52616b", "outline": "#bcc8cf", "outlineVariant": "#6f8792",
            "accent": "#0078d4", "danger": "#ff6b6b", "success": "#00aa00"
        },
        "dark": {
            "background": "#11181c", "surface": "#182126", "surfaceVariant": "#222d33",
            "surfaceContainerLow": "#172329", "surfaceContainer": "#1d272c", "surfaceContainerHigh": "#2a373e",
            "primary": "#62b5f5", "primaryContainer": "#173f59", "primaryText": "#081218",
            "text": "#edf4f7", "textSecondary": "#a9bac3", "outline": "#485961", "outlineVariant": "#526872",
            "accent": "#72c2ff", "danger": "#ff8a8a", "success": "#6bd58b"
        }
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
    readonly property string stateScript: Quickshell.shellDir + "/scripts/state/theme-state.sh"

    readonly property string currentPalette: hasPalette(configuredPalette) ? configuredPalette : (detectedPalettes.length > 0 ? detectedPalettes[0] : "qsitt")
    readonly property string currentMode: availableModes.includes(configuredMode) ? configuredMode : "light"
    readonly property string currentName: currentPalette + "-" + currentMode
    readonly property var current: paletteData[currentMode] ?? fallbackPalette[currentMode]

    readonly property FolderListModel paletteDirectory: FolderListModel {
        folder: Qt.resolvedUrl("../modules/common/theme/palettes")
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
        path: Quickshell.shellPath("modules/common/theme/palettes/" + root.currentPalette + ".toml")
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
        return { palette: palette.trim().toLowerCase(), mode: mode.trim().toLowerCase() };
    }

    function loadPalette(content: string): void {
        const parsed = { "light": {}, "dark": {} };
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
            const assignment = line.match(/^([A-Za-z0-9_-]+)\s*=\s*(.+)$/);
            if (assignment)
                parsed[section][assignment[1]] = tomlValue(assignment[2]);
        }

        paletteData = {
            "light": Object.assign({}, fallbackPalette.light, parsed.light),
            "dark": Object.assign({}, fallbackPalette.dark, parsed.dark)
        };
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
        function onReadyChanged(): void { root.finishLoad(); }
    }

    readonly property Process paletteLoader: Process {
        running: true
        command: ["sh", root.stateScript, "load-theme"]
        stdout: StdioCollector {
            onStreamFinished: root.savedPalette = text.trim()
        }
        onExited: {
            root.paletteLoadFinished = true;
            root.finishLoad();
        }
    }

    readonly property Process modeLoader: Process {
        running: true
        command: ["sh", root.stateScript, "load-mode"]
        stdout: StdioCollector {
            onStreamFinished: root.savedMode = text.trim()
        }
        onExited: {
            root.modeLoadFinished = true;
            root.finishLoad();
        }
    }

    readonly property Process paletteSaver: Process {
        property string pending: ""
        function save(name: string): void {
            if (running) {
                pending = name;
                return;
            }
            pending = "";
            exec(["sh", root.stateScript, "save-theme", name]);
        }
        onExited: {
            if (pending !== "") {
                const next = pending;
                pending = "";
                exec(["sh", root.stateScript, "save-theme", next]);
            }
        }
    }

    readonly property Process modeSaver: Process {
        property string pending: ""
        function save(name: string): void {
            if (running) {
                pending = name;
                return;
            }
            pending = "";
            exec(["sh", root.stateScript, "save-mode", name]);
        }
        onExited: {
            if (pending !== "") {
                const next = pending;
                pending = "";
                exec(["sh", root.stateScript, "save-mode", next]);
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
