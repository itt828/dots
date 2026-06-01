pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "."

Item {
    id: root

    property var workspaces: []
    
    // Internal state to track window titles for activity detection
    property var _windowTitles: ({}) // { windowId: title }

    function update(newWorkspaces) {
        if (!newWorkspaces || !Array.isArray(newWorkspaces)) return;
        
        // Preserve local urgency if it was set
        let oldWorkspaces = workspaces;
        workspaces = newWorkspaces.map(ws => {
            let oldWs = oldWorkspaces.find(o => o.id === ws.id);
            if (oldWs && oldWs.local_urgent && !ws.is_focused) {
                ws.is_urgent = true;
                ws.local_urgent = true;
            } else {
                ws.local_urgent = ws.is_urgent;
            }
            return ws;
        });
    }

    function setLocalUrgent(workspaceId, urgent) {
        workspaces = workspaces.map(ws => {
            if (ws.id === workspaceId) {
                ws.is_urgent = urgent;
                ws.local_urgent = urgent;
            }
            return ws;
        });
    }

    Connections {
        target: NiriService
        
        function onWorkspacesChanged(newWorkspaces) {
            update(newWorkspaces);
        }
        
        function onWorkspaceActivated(data) {
            // When a workspace is activated, update states and clear its local urgency
            let targetOutput = "";
            let wsToUpdate = workspaces.find(w => w.id === data.id);
            if (wsToUpdate) targetOutput = wsToUpdate.output;

            workspaces = workspaces.map(ws => {
                if (ws.id === data.id) {
                    return Object.assign({}, ws, {
                        is_active: true,
                        is_focused: true,
                        is_urgent: false,
                        local_urgent: false
                    });
                } else if (targetOutput !== "" && ws.output === targetOutput) {
                    return Object.assign({}, ws, {
                        is_active: false,
                        is_focused: false
                    });
                } else {
                    return ws;
                }
            });

            // Trigger a full refresh to be sure
            refreshWorkspaces.running = true;
        }

        function onWindowFocused(data) {
            refreshWorkspaces.running = true;
        }

        function onWindowFocusChanged(data) {
            refreshWorkspaces.running = true;
        }

        function onWindowOpenedOrChanged(window) {
            if (!window || !window.id || !window.workspace_id) return;
            
            let oldTitle = _windowTitles[window.id];
            let newTitle = window.title;
            _windowTitles[window.id] = newTitle;

            // Activity detection: title changed and window is NOT focused
            if (oldTitle !== undefined && oldTitle !== newTitle && !window.is_focused) {
                setLocalUrgent(window.workspace_id, true);
            }
            
            // Also handle explicit urgency flag from niri
            if (window.is_urgent) {
                setLocalUrgent(window.workspace_id, true);
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
