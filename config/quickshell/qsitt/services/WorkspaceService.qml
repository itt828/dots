pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var workspaces: []

    property var _windowTitles: ({})

    function update(newWorkspaces) {
        if (!newWorkspaces || !Array.isArray(newWorkspaces))
            return;

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

    function activateWorkspace(output: string, index: int): void {
        if (!output || index < 1)
            return;
        const args = ["niri", "focus", output, String(index)];
        if (focusProcess.running)
            focusProcess.pending = args;
        else
            focusProcess.execute(args);
    }

    Connections {
        target: NiriService

        function onWorkspacesChanged(newWorkspaces) {
            update(newWorkspaces);
        }

        function onWorkspaceActivated(data) {
            const target = workspaces.find(workspace => workspace.id === data.id);
            if (target) {
                workspaces = workspaces.map(workspace => {
                    const selected = workspace.id === data.id;
                    const focused = data.focused ? selected : workspace.is_focused;
                    return Object.assign({}, workspace, {
                        is_active: workspace.output === target.output ? selected : workspace.is_active,
                        is_focused: focused,
                        is_urgent: focused ? false : workspace.is_urgent,
                        local_urgent: focused ? false : workspace.local_urgent
                    });
                });
            }
            refreshWorkspaces.running = true;
        }

        function onWindowFocused(data) {
            refreshWorkspaces.running = true;
        }

        function onWindowFocusChanged(data) {
            refreshWorkspaces.running = true;
        }

        function onWindowOpenedOrChanged(window) {
            if (!window || !window.id || !window.workspace_id)
                return;

            let oldTitle = _windowTitles[window.id];
            let newTitle = window.title;
            _windowTitles[window.id] = newTitle;

            if (oldTitle !== undefined && oldTitle !== newTitle && !window.is_focused) {
                setLocalUrgent(window.workspace_id, true);
            }

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

    BackendProcess {
        id: refreshWorkspaces
        arguments: ["niri", "workspaces"]
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

    BackendProcess {
        id: initialFetch
        arguments: ["niri", "workspaces"]
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

    BackendProcess {
        id: syncWindows
        arguments: ["niri", "windows"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                if (!text)
                    return;
                try {
                    const windows = JSON.parse(text);
                    windows.forEach(win => {
                        _windowTitles[win.id] = win.title;
                    });
                } catch (e) {}
            }
        }
    }

    BackendProcess {
        id: focusProcess
        property var pending: null

        onExited: {
            if (pending) {
                const next = pending;
                pending = null;
                execute(next);
            }
        }
    }
}
