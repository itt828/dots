pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property bool visible: false
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

    readonly property string _helper: Quickshell.shellDir + "/scripts/unified-search.py"

    function refresh(): void { refreshTimer.restart(); }

    function open(): void {
        visible = true;
        refresh();
    }

    function close(): void {
        visible = false;
        query = "";
        category = "all";
    }

    function toggle(): void {
        if (visible) close(); else open();
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
        _actionProcess.command = ["xdg-open", "https://www.google.com/search?q=" + encodeURIComponent(value)];
        _actionProcess.running = true;
        close();
    }

    function activate(item: var): void {
        if (!item) return;
        if (item.kind === "web") { searchWeb(item.value); return; }
        if (item.kind === "lens") { startLensSelection(); return; }
        if (item.kind === "app") _actionProcess.command = ["gio", "launch", item.value];
        else if (item.kind === "file") _actionProcess.command = ["xdg-open", item.value];
        else if (item.kind === "clipboard" || item.kind === "clipboard-image" || item.kind === "clipboard-file") _actionProcess.command = ["python3", _helper, "clipboard-copy", item.value];
        else if (item.kind === "tool") {
            if (item.value === "lens") { startLensSelection(); return; }
            if (item.value === "control-center" || item.value === "notifications") {
                ControlCenterService.requestedPage = item.value === "notifications" ? 1 : 0;
                ControlCenterService.visible = true;
            }
            else if (item.value === "qr") ControlCenterService.startQrSelection();
            else if (item.value === "color") ControlCenterService.pickColor();
            else if (item.value === "lock") PowerService.lock();
            else if (item.value === "suspend") PowerService.suspend();
            else if (item.value === "screenshot") _actionProcess.command = ["niri", "msg", "action", "screenshot"];
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

    readonly property Timer refreshTimer: Timer {
        interval: 100
        onTriggered: {
            if (root._queryProcess.running) return;
            root._activeQuery = root.query;
            root._activeCategory = root.category;
            root._response = "";
            root._queryProcess.command = ["python3", root._helper, "query", root._activeQuery, root._activeCategory];
            root._queryProcess.running = true;
        }
    }

    readonly property Process _queryProcess: Process {
        stdout: StdioCollector {
            onStreamFinished: root._response = text
        }
        onExited: {
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

    readonly property Process _indexProcess: Process {
        running: true
        command: ["python3", root._helper, "index"]
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

    readonly property Process _clipboardWatcher: Process {
        running: true
        command: ["wl-paste", "--type", "text", "--watch", "python3", root._helper, "clipboard-add"]
        onExited: root._watchRestart.start()
    }

    readonly property Process _imageWatcher: Process {
        running: true
        command: ["wl-paste", "--type", "image", "--watch", "python3", root._helper, "clipboard-add-image"]
        onExited: root._watchRestart.start()
    }

    readonly property Process _fileWatcher: Process {
        running: true
        command: ["wl-paste", "--type", "text/uri-list", "--watch", "python3", root._helper, "clipboard-add-files"]
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

    readonly property Process _clearClipboardProcess: Process {
        command: ["python3", root._helper, "clipboard-clear"]
        onExited: root.refresh()
    }

    readonly property Process _actionProcess: Process {}

    readonly property Process _lensProcess: Process {
        running: root.lensBusy
        command: ["bash", Quickshell.shellDir + "/scripts/google-lens-region.sh", root.lensGeometry]
        onExited: root.lensBusy = false
    }
}
