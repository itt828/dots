import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    signal workspacesChanged(var workspaces)
    signal workspaceActivated(var data)
    signal windowFocused(var data)
    signal windowFocusChanged(var data)
    signal windowsChanged(var windows)
    signal windowOpenedOrChanged(var window)
    signal windowUrgencyChanged(var data)

    Process {
        id: niriEventStream
        command: ["stdbuf", "-oL", "niri", "msg", "-j", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const line = data.toString().trim();
                if (!line) return;
                
                // Use print for more reliable console output in some environments
                // print("[NiriService] Raw:", line); 

                try {
                    const event = JSON.parse(line);
                    if (event.WorkspacesChanged) {
                        root.workspacesChanged(event.WorkspacesChanged.workspaces);
                    }
                    if (event.WorkspaceActivated) {
                        root.workspaceActivated(event.WorkspaceActivated);
                    }
                    if (event.WindowFocused) {
                        root.windowFocused(event.WindowFocused);
                    }
                    if (event.WindowFocusChanged) {
                        root.windowFocusChanged(event.WindowFocusChanged);
                    }
                    if (event.WindowsChanged) {
                        root.windowsChanged(event.WindowsChanged.windows);
                    }
                    if (event.WindowOpenedOrChanged) {
                        print("[NiriService] Window Event:", event.WindowOpenedOrChanged.window.title);
                        root.windowOpenedOrChanged(event.WindowOpenedOrChanged.window);
                    }
                    if (event.WindowUrgencyChanged) {
                        root.windowUrgencyChanged(event.WindowUrgencyChanged);
                    }
                } catch (e) {
                    print("[NiriService] Error parsing JSON:", e);
                }
            }
        }
        
        onExited: restartTimer.start()
    }

    Timer {
        id: restartTimer
        interval: 1000
        onTriggered: niriEventStream.running = true
    }
}
