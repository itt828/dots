import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Row {
    id: root
    spacing: 5
    
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
                            modelData.menu.open()
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
