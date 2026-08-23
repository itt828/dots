import QtQuick
import Quickshell
import QtQuick.Layouts
import "../Assets"
import "Bar"

Scope {
    id: root
    required property var workspaceStore

    Variants {
        model: Quickshell.screens.filter((screen, index) => {
            if (Config.targetScreens.length > 0) {
                return !Config.targetScreens.includes(screen.name);
            }
            return index !== 0;
        })

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            exclusiveZone: 0

            property int fullHeight: 32
            property int hiddenHeight: 1
            property bool isHovered: hoverArea.containsMouse

            implicitHeight: isHovered ? fullHeight : hiddenHeight

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: 10
                }
            }

            color: "transparent"
            Base {
                anchors.fill: parent
                color: "#abcabc"
                clip: true
                centerContent: RowLayout {
                    Workspaces {
                        workspaceStore: root.workspaceStore
                        outputName: modelData.name
                    }
                }
            }
            MouseArea {
                id: hoverArea
                anchors.fill: parent
                hoverEnabled: true
            }
        }
    }
}
