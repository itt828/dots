import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../Components"
import "../../Services"
import "../../Assets"

Item {
    id: root
    width: layout.implicitWidth
    height: layout.implicitHeight
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    RowLayout {
        id: layout
        spacing: 8

        Repeater {
            model: WorkspaceStore.count
            
            Rectangle {
                property int workspaceIdx: index + 1
                width: 16
                height: 16
                radius: 2
                color: {
                    if (workspaceIdx === WorkspaceStore.currentIndex) return Theme.accent;
                    if (WorkspaceStore.urgentMask & (1 << workspaceIdx)) return Theme.danger;
                    return Theme.surfaceVariant;
                }
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        switchProcess.command = ["niri", "msg", "action", "focus-workspace", workspaceIdx.toString()]
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
