pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

QtObject {
    property bool visible: false
    property string query: ""
    property bool lensSelecting: false
    property bool lensBusy: false
    property string lensGeometry: ""

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
}
