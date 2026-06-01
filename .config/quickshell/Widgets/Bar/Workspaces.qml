import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../Components"
import "../../Services"
import "../../Assets"

Item {
    id: root
    property string outputName: ""
    width: layout.implicitWidth
    height: layout.implicitHeight
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    RowLayout {
        id: layout
        spacing: 8

        Repeater {
            model: WorkspaceStore.workspaces
                    .filter(ws => ws.output === root.outputName)
                    .sort((a, b) => a.idx - b.idx)
            
            Rectangle {
                width: 16
                height: 16
                radius: 2
                color: {
                    if (modelData.is_focused) return Theme.accent;
                    if (modelData.is_active) return "#505050"; // Darker gray for active but unfocused
                    if (modelData.is_urgent) return Theme.danger;
                    return Theme.surfaceVariant;
                }
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        let cmd = `niri msg action focus-monitor "${root.outputName}"; niri msg action focus-workspace ${modelData.idx}`;
                        switchProcess.command = ["bash", "-c", cmd]
                        switchProcess.running = true
                    }
                }
            }
        }
    }

    Process {
        id: switchProcess
    }
}
