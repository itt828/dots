import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Row {
    id: root
    spacing: 5

    required property var rootWindow
    
    Repeater {
        model: SystemTray.items
        
        delegate: Column {
            spacing: 4 // Match BarValue spacing
            
            Image {
                width: 20
                height: 20
                source: modelData.icon
                fillMode: Image.PreserveAspectFit
                
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            modelData.activate()
                        } else if (mouse.button === Qt.RightButton) {
                            var pos = mapToItem(null, mouse.x, mouse.y)
                            modelData.display(root.rootWindow, pos.x, pos.y)
                        }
                    }
                }
            }
            
            // Spacer to match BarValue's progress bar area
            Item {
                width: 20
                height: 2 // Match BarValue bar height
            }
        }
    }
}
