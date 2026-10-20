pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property string content: ""
    property bool ready: false

    readonly property FileView configFile: FileView {
        path: Quickshell.shellPath("config.toml")
        blockLoading: true
        onLoaded: {
            root.content = text();
            root.ready = true;
        }
        onLoadFailed: error => {
            console.warn("Failed to load legacy config.toml:", error);
            root.ready = true;
        }
    }

    Component.onCompleted: configFile.reload()
}
