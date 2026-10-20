pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    property bool visible: false
    property string query: ""
    property bool lensSelecting: false
    property bool lensBusy: false
    property string lensGeometry: ""

    function submit(): void {
        const value = query.trim();
        if (value.length === 0)
            return;

        _openUrlProcess.command = ["xdg-open", "https://www.google.com/search?q=" + encodeURIComponent(value)];
        _openUrlProcess.running = true;
        close();
    }

    function open(): void {
        visible = true;
    }

    function close(): void {
        visible = false;
        query = "";
    }

    function toggle(): void {
        if (visible)
            close();
        else
            open();
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

    readonly property Process _openUrlProcess: Process {}

    readonly property Process _lensProcess: Process {
        running: lensBusy
        command: ["bash", Quickshell.shellDir + "/scripts/google-lens-region.sh", lensGeometry]
        onExited: (exitCode, exitStatus) => lensBusy = false
    }
}
