pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    // Palette colors live in Theme/Palettes/<name>.toml.
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
    property string _configText: ""
    property var paletteData: fallbackPalette

    readonly property string currentPalette: hasPalette(configuredPalette) ? configuredPalette : (detectedPalettes.length > 0 ? detectedPalettes[0] : "qsitt")
    readonly property string currentMode: availableModes.includes(configuredMode) ? configuredMode : "light"
    readonly property string currentName: currentPalette + "-" + currentMode
    readonly property var current: paletteData[currentMode] ?? fallbackPalette[currentMode]

    readonly property FileView configFile: FileView {
        path: Quickshell.shellPath("config.toml")
        blockLoading: true
        blockWrites: true
        atomicWrites: true
        watchChanges: true

        onLoaded: root.loadConfig(text())
        onFileChanged: configReloadTimer.restart()
        onLoadFailed: error => console.warn("Failed to load config.toml:", error)
    }

    readonly property Timer configReloadTimer: Timer {
        interval: 50
        onTriggered: root.configFile.reload()
    }

    readonly property FolderListModel paletteDirectory: FolderListModel {
        folder: Qt.resolvedUrl("Palettes")
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
        path: Quickshell.shellPath("Theme/Palettes/" + root.currentPalette + ".toml")
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
        configFile.reload();
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

    function tomlComment(line: string): string {
        let quote = "";
        for (let index = 0; index < line.length; index++) {
            const character = line[index];
            if ((character === "\"" || character === "'") && (index === 0 || line[index - 1] !== "\\"))
                quote = quote === "" ? character : (quote === character ? "" : quote);
            else if (character === "#" && quote === "")
                return line.slice(index).trim();
        }
        return "";
    }

    function loadConfig(content: string): void {
        _configText = content;
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

        configuredPalette = palette.trim().toLowerCase();
        configuredMode = mode.trim().toLowerCase();
        if (!hasPalette(configuredPalette))
            console.warn("Unknown theme palette in config.toml:", configuredPalette, "- using qsitt");
        if (!availableModes.includes(configuredMode))
            console.warn("Unknown theme mode in config.toml:", configuredMode, "- using light");
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

    function configWithThemeValue(content: string, key: string, value: string): string {
        const lines = content.split(/\r?\n/);
        let themeStart = -1;
        let themeEnd = lines.length;
        let keyIndex = -1;

        for (let index = 0; index < lines.length; index++) {
            const sectionMatch = stripTomlComment(lines[index]).trim().match(/^\[([^\]]+)\]$/);
            if (!sectionMatch)
                continue;
            if (themeStart >= 0) {
                themeEnd = index;
                break;
            }
            if (sectionMatch[1].trim() === "theme")
                themeStart = index;
        }

        if (themeStart < 0) {
            if (lines.length > 0 && lines[lines.length - 1] !== "")
                lines.push("");
            lines.push("[theme]", key + " = \"" + value + "\"");
            return lines.join("\n");
        }

        for (let index = themeStart + 1; index < themeEnd; index++) {
            const assignment = stripTomlComment(lines[index]).trim().match(/^([A-Za-z0-9_-]+)\s*=/);
            if (assignment && assignment[1] === key) {
                keyIndex = index;
                break;
            }
        }

        const newLine = key + " = \"" + value + "\"";
        if (keyIndex >= 0) {
            const indentation = lines[keyIndex].match(/^\s*/)[0];
            const comment = tomlComment(lines[keyIndex]);
            lines[keyIndex] = indentation + newLine + (comment === "" ? "" : " " + comment);
        } else {
            lines.splice(themeEnd, 0, newLine);
        }
        return lines.join("\n");
    }

    function saveThemeValue(key: string, value: string): void {
        const nextConfig = configWithThemeValue(_configText, key, value);
        _configText = nextConfig;
        configFile.setText(nextConfig);
    }

    function setPalette(name: string): bool {
        const normalizedName = name.trim().toLowerCase();
        if (!hasPalette(normalizedName))
            return false;
        configuredPalette = normalizedName;
        saveThemeValue("palette", normalizedName);
        return true;
    }

    function setMode(mode: string): bool {
        const normalizedMode = mode.trim().toLowerCase();
        if (!availableModes.includes(normalizedMode))
            return false;
        configuredMode = normalizedMode;
        saveThemeValue("mode", normalizedMode);
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

    readonly property color background: current.background
    readonly property color surface: current.surface
    readonly property color surfaceVariant: current.surfaceVariant
    readonly property color surfaceContainerLow: current.surfaceContainerLow
    readonly property color surfaceContainer: current.surfaceContainer
    readonly property color surfaceContainerHigh: current.surfaceContainerHigh
    readonly property color primary: current.primary
    readonly property color primaryContainer: current.primaryContainer
    readonly property color primaryText: current.primaryText
    readonly property color text: current.text
    readonly property color textSecondary: current.textSecondary
    readonly property color outline: current.outline
    readonly property color outlineVariant: current.outlineVariant
    readonly property color accent: current.accent
    readonly property color danger: current.danger
    readonly property color success: current.success

    readonly property string fontFamily: "sans-serif"
    readonly property int fontSizeSmall: 11
    readonly property int fontSizeBody: 13
    readonly property int fontSizeTitle: 20

    readonly property int radius: 8
    readonly property int radiusSmall: 6
    readonly property int radiusLarge: 18
    readonly property int padding: 10
    readonly property int spacing: 10
    readonly property int spacingSmall: 6
    readonly property int spacingLarge: 16

    function withAlpha(color: color, alpha: real): color {
        return Qt.rgba(color.r, color.g, color.b, alpha);
    }

    readonly property int barBorderWidth: 2
    readonly property int barHeight: 32
    readonly property int barOuterMargin: 8
    readonly property int barHorizontalPadding: 12
    readonly property int barSectionSpacing: 12
    readonly property int barModuleSpacing: 8
}
