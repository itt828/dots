pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property bool visible: false
    property string focusedOutputName: ""
    property bool _opening: false
    property string query: ""
    readonly property var scopes: [
        {
            key: "all",
            label: "すべて",
            prefix: ""
        },
        {
            key: "apps",
            label: "アプリ",
            prefix: "/a"
        },
        {
            key: "tools",
            label: "ツール",
            prefix: "/t"
        },
        {
            key: "files",
            label: "ファイル",
            prefix: "/f"
        },
        {
            key: "clipboard",
            label: "履歴",
            prefix: "/c"
        },
        {
            key: "web",
            label: "Web",
            prefix: "/w"
        },
        {
            key: "calc",
            label: "計算",
            prefix: "="
        }
    ]
    readonly property var parsed: parse(query)
    readonly property string category: parsed.category
    readonly property bool choosingScope: query.trim() === "/"
    readonly property var results: choosingScope ? scopes.slice(1).map(scope => ({
                kind: "scope",
                value: scope.key,
                title: scope.label,
                subtitle: scope.prefix
            })) : _results
    readonly property bool searching: visible && !choosingScope && (refreshTimer.running || _queryProcess.running)
    property var _results: []
    property int selectedIndex: 0
    property bool lensSelecting: false
    property bool lensBusy: false
    property string lensGeometry: ""
    property string _activeQuery: ""
    property string _activeCategory: ""
    property string _response: ""

    function parse(value: string): var {
        const input = value.replace(/^\s+/, "");
        if (input.startsWith("="))
            return {
                category: "calc",
                text: input.slice(1).trim()
            };
        const match = /^\/[atfcw](?=\s|$)/i.exec(input);
        const scope = match && scopes.find(item => item.prefix === match[0].toLowerCase());
        return scope ? {
            category: scope.key,
            text: input.slice(match[0].length).trim()
        } : {
            category: "all",
            text: input.trim()
        };
    }

    onQueryChanged: {
        _results = [];
        selectedIndex = 0;
        refresh();
    }

    function refresh(): void {
        if (visible && !choosingScope)
            refreshTimer.restart();
        else
            refreshTimer.stop();
    }

    function openOnOutput(outputName: string, scope: string): void {
        close();
        if (scope !== "")
            setCategory(scope);
        if (outputName)
            showOnOutput(outputName);
        else
            open();
    }

    function showOnOutput(outputName: string): void {
        ControlCenterService.visible = false;
        PowerService.visible = false;
        NotificationService.panelVisible = false;
        focusedOutputName = outputName;
        visible = true;
        refresh();
    }

    function open(): void {
        visible = false;
        _opening = true;
        focusedOutputName = "";
        if (!_focusedOutputProcess.running)
            _focusedOutputProcess.running = true;
    }

    function close(): void {
        _opening = false;
        visible = false;
        query = "";
        _results = [];
        selectedIndex = 0;
    }

    function toggle(): void {
        if (visible || _opening)
            close();
        else
            open();
    }

    function setCategory(value: string): void {
        const scope = scopes.find(item => item.key === value);
        if (!scope)
            return;
        const terms = choosingScope ? "" : parsed.text;
        query = scope.prefix + (scope.prefix && scope.prefix !== "=" ? " " : "") + terms;
        selectedIndex = 0;
    }

    function submit(): void {
        if (results.length > 0)
            activate(results[Math.min(selectedIndex, results.length - 1)]);
        else if (category === "web" && parsed.text)
            searchWeb(parsed.text);
    }

    function searchWeb(value: string): void {
        _actionProcess.arguments = ["open", "https://www.google.com/search?q=" + encodeURIComponent(value)];
        _actionProcess.running = true;
        close();
    }

    function activate(item: var): void {
        if (!item)
            return;
        if (item.kind === "scope") {
            setCategory(item.value);
            return;
        }
        if (item.kind === "calculation") {
            _actionProcess.execute(["clipboard", "copy-text", item.value]);
            close();
            return;
        }
        if (item.kind === "web") {
            searchWeb(item.value);
            return;
        }
        if (item.kind === "lens") {
            startLensSelection();
            return;
        }
        if (item.kind === "app") {
            _actionProcess.arguments = ["launch", item.value];
            _actionProcess.running = true;
            close();
            return;
        }
        if (item.kind === "file")
            _actionProcess.arguments = ["open", item.value];
        else if (item.kind === "clipboard" || item.kind === "clipboard-image" || item.kind === "clipboard-file")
            _actionProcess.arguments = ["clipboard", "copy", item.value];
        else if (item.kind === "tool") {
            if (item.value === "lens") {
                startLensSelection();
                return;
            }
            const pages = {
                "control-center": 0,
                calendar: 1,
                monitor: 2,
                focus: 3,
                audio: 4,
                network: 5,
                bluetooth: 6,
                settings: 7
            };
            if (item.value in pages || item.value === "notifications" || item.value === "record") {
                const output = focusedOutputName;
                close();
                if (item.value === "notifications") {
                    ControlCenterService.visible = false;
                    NotificationService.openFor(output);
                } else if (item.value === "record") {
                    RecorderService.toggle(output);
                } else {
                    ControlCenterService.openPage(pages[item.value], output);
                }
                return;
            }
            if (item.value === "qr")
                ControlCenterService.startQrSelection();
            else if (item.value === "color")
                ControlCenterService.pickColor();
            else if (item.value === "lock")
                PowerService.lock();
            else if (item.value === "suspend")
                PowerService.suspend();
            else if (item.value === "screenshot")
                _actionProcess.arguments = ["niri", "screenshot"];
            else
                return;
            if (item.value !== "screenshot") {
                close();
                return;
            }
        } else
            return;
        _actionProcess.running = true;
        close();
    }

    function clearClipboard(): void {
        _clearClipboardProcess.running = true;
    }

    function startLensSelection(): void {
        if (lensSelecting || lensBusy)
            return;
        close();
        lensSelecting = true;
    }

    function finishLensSelection(geometry: string): void {
        lensGeometry = geometry;
        lensSelecting = false;
        lensBusy = true;
    }

    function cancelLensSelection(): void {
        lensSelecting = false;
    }

    readonly property BackendProcess _focusedOutputProcess: BackendProcess {
        arguments: ["niri", "focused-output"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const output = JSON.parse(text);
                    if (root._opening)
                        root.focusedOutputName = output?.name || "";
                } catch (e) {
                    if (root._opening)
                        root.focusedOutputName = "";
                }
            }
        }
        onExited: {
            if (!root._opening)
                return;
            if (!root.focusedOutputName && Quickshell.screens.length > 0)
                root.focusedOutputName = Quickshell.screens[0].name;
            root._opening = false;
            root.showOnOutput(root.focusedOutputName);
        }
    }

    readonly property Timer refreshTimer: Timer {
        interval: 100
        onTriggered: {
            if (root._queryProcess.running)
                return;
            root._activeQuery = root.parsed.text;
            root._activeCategory = root.category;
            root._response = "";
            root._queryProcess.arguments = ["search", "query", root._activeQuery, root._activeCategory];
            root._queryProcess.running = true;
        }
    }

    readonly property BackendProcess _queryProcess: BackendProcess {
        stdout: StdioCollector {
            onStreamFinished: root._response = text
        }
        onExited: {
            if (!root.visible || root.choosingScope)
                return;
            if (root._activeQuery !== root.parsed.text || root._activeCategory !== root.category) {
                root.refresh();
                return;
            }
            try {
                root._results = JSON.parse(root._response);
                root.selectedIndex = 0;
            } catch (e) {
                root._results = [];
                console.warn("Search query failed:", e);
            }
        }
    }

    readonly property BackendProcess _indexProcess: BackendProcess {
        running: true
        arguments: ["search", "index"]
        onExited: root.refresh()
    }

    readonly property Timer _indexRefresh: Timer {
        interval: 600000
        running: true
        repeat: true
        onTriggered: {
            if (!root._indexProcess.running)
                root._indexProcess.running = true;
        }
    }

    readonly property BackendProcess _clipboardWatcher: BackendProcess {
        running: true
        arguments: ["clipboard", "watch", "text"]
        onExited: root._watchRestart.start()
    }

    readonly property BackendProcess _imageWatcher: BackendProcess {
        running: true
        arguments: ["clipboard", "watch", "image"]
        onExited: root._watchRestart.start()
    }

    readonly property BackendProcess _fileWatcher: BackendProcess {
        running: true
        arguments: ["clipboard", "watch", "text/uri-list"]
        onExited: root._watchRestart.start()
    }

    readonly property Timer _watchRestart: Timer {
        interval: 3000
        onTriggered: {
            if (!root._clipboardWatcher.running)
                root._clipboardWatcher.running = true;
            if (!root._imageWatcher.running)
                root._imageWatcher.running = true;
            if (!root._fileWatcher.running)
                root._fileWatcher.running = true;
        }
    }

    readonly property BackendProcess _clearClipboardProcess: BackendProcess {
        arguments: ["clipboard", "clear"]
        onExited: root.refresh()
    }

    readonly property BackendProcess _actionProcess: BackendProcess {}

    readonly property BackendProcess _lensProcess: BackendProcess {
        running: root.lensBusy
        arguments: ["tool", "lens", root.lensGeometry]
        onExited: root.lensBusy = false
    }
}
