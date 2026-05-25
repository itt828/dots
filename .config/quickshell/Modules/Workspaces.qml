import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../Widgets"
import "../Common"

Row {
    id: root
    spacing: 5
    padding: 5

    property var workspaces: []
    property int activeIdx: -1

    // Initial fetch and periodic refresh as fallback
    Process {
        id: fetchWorkspaces
        command: ["niri", "msg", "--json", "workspaces"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text) {
                    try {
                        const data = JSON.parse(text);
                        data.sort((a, b) => a.idx - b.idx);
                        root.workspaces = data;
                        const active = data.find(w => w.is_active);
                        if (active) root.activeIdx = active.idx;
                    } catch (e) {
                        console.error("Failed to parse workspaces:", e);
                    }
                }
            }
        }
    }

    // Listener for niri events
    Process {
        id: niriEvents
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: StdioCollector {
            onLineRead: (line) => {
                // Any event might mean something changed, but let's just re-fetch
                fetchWorkspaces.running = false
                fetchWorkspaces.running = true
            }
        }
    }

    Timer {
        interval: 10000 // periodic refresh just in case
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            fetchWorkspaces.running = false
            fetchWorkspaces.running = true
        }
    }

    Repeater {
        model: root.workspaces
        delegate: Rectangle {
            width: 24
            height: 24
            radius: 12
            color: modelData.is_active ? "black" : "transparent"
            border.width: 1
            border.color: "black"
            opacity: modelData.is_active ? 1.0 : 0.6

            AText {
                anchors.centerIn: parent
                text: modelData.idx.toString()
                color: modelData.is_active ? "white" : "black"
                font.pixelSize: 12
                font.bold: modelData.is_active
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    const proc = Qt.createQmlObject('import Quickshell.Io; Process {}', root);
                    proc.command = ["niri", "msg", "action", "focus-workspace", modelData.idx.toString()];
                    proc.running = true;
                }
            }
        }
    }
}
