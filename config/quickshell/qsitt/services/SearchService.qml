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
    property string category: "all"
    property var results: []
    property int selectedIndex: 0
    property bool lensSelecting: false
    property bool lensBusy: false
    property string lensGeometry: ""
    property string _activeQuery: ""
    property string _activeCategory: ""
    property string _response: ""

    function refresh(): void { refreshTimer.restart(); }

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
        category = "all";
        results = [];
        selectedIndex = 0;
    }

    function toggle(): void {
        if (visible || _opening) close(); else open();
    }

    function setCategory(value: string): void {
        category = value;
        selectedIndex = 0;
        refresh();
    }

    function submit(): void {
        if (results.length > 0) activate(results[Math.min(selectedIndex, results.length - 1)]);
        else if (query.trim()) searchWeb(query.trim());
    }

    function searchWeb(value: string): void {
        _actionProcess.arguments = ["open", "https://www.google.com/search?q=" + encodeURIComponent(value)];
        _actionProcess.running = true;
        close();
    }

    function activate(item: var): void {
        if (!item) return;
        if (item.kind === "web") { searchWeb(item.value); return; }
        if (item.kind === "lens") { startLensSelection(); return; }
        if (item.kind === "app") {
            _actionProcess.arguments = ["launch", item.value];
            _actionProcess.running = true;
            close();
            return;
        }
        if (item.kind === "file") _actionProcess.arguments = ["open", item.value];
        else if (item.kind === "clipboard" || item.kind === "clipboard-image" || item.kind === "clipboard-file") _actionProcess.arguments = ["clipboard", "copy", item.value];
        else if (item.kind === "tool") {
            if (item.value === "lens") { startLensSelection(); return; }
            if (item.value === "control-center" || item.value === "notifications") {
                ControlCenterService.requestedPage = 0;
                ControlCenterService.visible = item.value === "control-center";
                NotificationService.panelVisible = item.value === "notifications";
            }
            else if (item.value === "qr") ControlCenterService.startQrSelection();
            else if (item.value === "color") ControlCenterService.pickColor();
            else if (item.value === "lock") PowerService.lock();
            else if (item.value === "suspend") PowerService.suspend();
            else if (item.value === "screenshot") _actionProcess.arguments = ["niri", "screenshot"];
            else return;
            if (item.value !== "screenshot") { close(); return; }
        } else return;
        _actionProcess.running = true;
        close();
    }

    function clearClipboard(): void {
        _clearClipboardProcess.running = true;
    }

    function startLensSelection(): void {
        if (lensSelecting || lensBusy) return;
        close();
        lensSelecting = true;
    }

    function finishLensSelection(geometry: string): void {
        lensGeometry = geometry;
        lensSelecting = false;
        lensBusy = true;
    }

    function cancelLensSelection(): void { lensSelecting = false; }

    readonly property BackendProcess _focusedOutputProcess: BackendProcess {
        arguments: ["niri", "focused-output"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const output = JSON.parse(text);
                    root.focusedOutputName = output?.name || "";
                } catch (e) {
                    root.focusedOutputName = "";
                }
            }
        }
        onExited: {
            if (!root._opening) return;
            if (!root.focusedOutputName && Quickshell.screens.length > 0)
                root.focusedOutputName = Quickshell.screens[0].name;
            root._opening = false;
            root.visible = true;
            root.refresh();
        }
    }

    readonly property Timer refreshTimer: Timer {
        interval: 100
        onTriggered: {
            if (root._queryProcess.running) return;
            root._activeQuery = root.query;
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
            if (!root.visible) return;
            if (root._activeQuery !== root.query || root._activeCategory !== root.category) {
                root.refresh();
                return;
            }
            try {
                root.results = JSON.parse(root._response);
                root.selectedIndex = 0;
            } catch (e) {
                root.results = [];
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
            if (!root._indexProcess.running) root._indexProcess.running = true;
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
            if (!root._clipboardWatcher.running) root._clipboardWatcher.running = true;
            if (!root._imageWatcher.running) root._imageWatcher.running = true;
            if (!root._fileWatcher.running) root._fileWatcher.running = true;
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
