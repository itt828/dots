pragma Singleton
import QtQuick
import Quickshell.Io
import "."

Item {
    id: root

    property string focusedWindowTitle: ""

    function updateFocusedWindow() {
        focusedWindowFetch.running = true;
    }

    Connections {
        target: NiriService
        
        function onWindowFocused(data) {
            updateFocusedWindow();
        }

        function onWindowFocusChanged(data) {
            updateFocusedWindow();
        }

        function onWorkspaceActivated(data) {
            updateFocusedWindow();
        }

        function onWindowOpenedOrChanged(window) {
            if (window.is_focused) {
                root.focusedWindowTitle = window.title || "";
            }
        }

        function onWindowsChanged(windows) {
            updateFocusedWindow();
        }
    }

    Process {
        id: focusedWindowFetch
        command: ["niri", "msg", "-j", "focused-window"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text) {
                    try {
                        const win = JSON.parse(text);
                        root.focusedWindowTitle = win.title || "";
                    } catch (e) {
                        root.focusedWindowTitle = "";
                    }
                } else {
                    root.focusedWindowTitle = "";
                }
            }
        }
    }

    Component.onCompleted: updateFocusedWindow()
}
