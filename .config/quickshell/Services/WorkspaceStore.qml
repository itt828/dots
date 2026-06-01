pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "."

Item {
    id: root

    property int count: 0
    property int currentIndex: -1
    property var _workspaces: []
    property int urgentMask: 0
    
    // Internal state to track window titles for activity detection
    property var _windowTitles: ({}) // { windowId: title }

    function update(workspaces) {
        if (!workspaces || !Array.isArray(workspaces)) return;
        
        _workspaces = workspaces;
        root.count = workspaces.length;
        
        let newMask = urgentMask;
        for (let i = 0; i < workspaces.length; i++) {
            const ws = workspaces[i];
            
            // If niri says it's urgent, mark it
            if (ws.is_urgent) {
                newMask |= (1 << ws.idx);
            }

            if (ws.is_focused || ws.is_active) {
                root.currentIndex = ws.idx;
                // Clear urgency when focusing
                if (ws.is_focused) {
                    newMask &= ~(1 << ws.idx);
                }
            }
        }
        urgentMask = newMask;
    }

    Connections {
        target: NiriService
        
        function onWorkspacesChanged(workspaces) {
            update(workspaces);
        }
        
        function onWorkspaceActivated(data) {
            for (let i = 0; i < _workspaces.length; i++) {
                if (_workspaces[i].id === data.id) {
                    root.currentIndex = _workspaces[i].idx;
                    urgentMask &= ~(1 << root.currentIndex);
                    break;
                }
            }
        }

        function onWindowOpenedOrChanged(window) {
            if (!window || !window.id || !window.workspace_id) return;
            
            let oldTitle = _windowTitles[window.id];
            let newTitle = window.title;
            _windowTitles[window.id] = newTitle;

            // Activity detection: title changed and window is NOT focused
            if (oldTitle !== undefined && oldTitle !== newTitle && !window.is_focused) {
                // Find workspace index for this ID
                for (let i = 0; i < _workspaces.length; i++) {
                    if (_workspaces[i].id === window.workspace_id) {
                        let idx = _workspaces[i].idx;
                        if (idx !== root.currentIndex) {
                            urgentMask |= (1 << idx);
                        }
                        break;
                    }
                }
            }
            
            // Also handle explicit urgency flag from niri
            if (window.is_urgent) {
                for (let i = 0; i < _workspaces.length; i++) {
                    if (_workspaces[i].id === window.workspace_id) {
                        urgentMask |= (1 << _workspaces[i].idx);
                        break;
                    }
                }
            }
        }

        function onWindowUrgencyChanged(data) {
            if (data.urgent) {
                refreshWorkspaces.running = true;
            }
        }
    }

    Process {
        id: refreshWorkspaces
        command: ["niri", "msg", "-j", "workspaces"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text) {
                    try {
                        update(JSON.parse(text));
                    } catch (e) {}
                }
            }
        }
    }

    Process {
        id: initialFetch
        command: ["niri", "msg", "-j", "workspaces"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                if (text) {
                    try {
                        update(JSON.parse(text));
                    } catch (e) {}
                }
            }
        }
    }

    // Periodically sync window titles to handle initial state or missed events
    Process {
        id: syncWindows
        command: ["niri", "msg", "-j", "windows"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                if (!text) return;
                try {
                    const windows = JSON.parse(text);
                    windows.forEach(win => {
                        _windowTitles[win.id] = win.title;
                    });
                } catch (e) {}
            }
        }
    }
}
