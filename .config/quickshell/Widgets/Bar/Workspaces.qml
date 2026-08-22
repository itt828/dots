import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../Components"
import "../../Services"
import "../../Assets"

Item {
    id: root
    required property var workspaceStore
    property string outputName: ""
    property bool showOtherOutputs: false
    readonly property var displayEntries: {
        const all = workspaceStore.workspaces || [];
        const outputs = [root.outputName];

        if (root.showOtherOutputs) {
            all.forEach(ws => {
                if (ws.output !== root.outputName && !outputs.includes(ws.output))
                    outputs.push(ws.output);
            });
        }

        const entries = [];
        outputs.forEach(output => {
            const outputWorkspaces = all
                .filter(ws => ws.output === output)
                .sort((a, b) => a.idx - b.idx);

            if (outputWorkspaces.length === 0)
                return;
            if (entries.length > 0)
                entries.push({ separator: true });
            outputWorkspaces.forEach(ws => entries.push({ workspace: ws }));
        });
        return entries;
    }
    width: layout.implicitWidth
    height: layout.implicitHeight
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    RowLayout {
        id: layout
        spacing: 8

        Repeater {
            model: root.displayEntries

            Item {
                required property var modelData
                readonly property var workspace: modelData.workspace
                implicitWidth: modelData.separator ? separator.implicitWidth : 16
                implicitHeight: 16

                Text {
                    id: separator
                    anchors.centerIn: parent
                    visible: modelData.separator === true
                    text: "|"
                    color: Theme.textSecondary
                }

                Rectangle {
                    anchors.fill: parent
                    visible: !modelData.separator
                    radius: 2
                    color: {
                        if (!workspace) return Theme.surfaceVariant;
                        if (workspace.is_focused) return Theme.accent;
                        if (workspace.is_active) return "#505050"; // Darker gray for active but unfocused
                        if (workspace.is_urgent) return Theme.danger;
                        return Theme.surfaceVariant;
                    }

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: parent.visible
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            let cmd = `niri msg action focus-monitor "${workspace.output}"; niri msg action focus-workspace ${workspace.idx}`;
                            switchProcess.command = ["bash", "-c", cmd]
                            switchProcess.running = true
                        }
                    }
                }
            }
        }
    }

    Process {
        id: switchProcess
    }
}
