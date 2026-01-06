import Quickshell
import QtQuick
import QtQuick.Effects
import "../components"
import "../components/Dashboard"
// Import the singleton component
// Note: In some setups, importing "." in components/qmldir is needed, or importing "components" here.
// Since DashboardContext is in ../components and has a qmldir, importing "../components" should work.

Scope {
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            id: dashboardWindow
            
            // Bind visibility to the singleton
            visible: DashboardContext.visible
            
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            color: "transparent"
            
            // Background Click Catcher
            MouseArea {
                anchors.fill: parent
                onClicked: DashboardContext.visible = false
            }
            
            // Dashboard Content
            Rectangle {
                id: dashboardContent
                
                // Position aligned with the clock (approx)
                x: 8 + 12 
                y: 50 
                
                width: 320
                height: contentCol.implicitHeight + 20
                color: "#eeeeee"
                radius: 16
                border.color: "#cccccc"
                border.width: 1
                
                // Eat clicks so they don't close the dashboard
                MouseArea {
                    anchors.fill: parent
                }
                
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: "black"
                    shadowOpacity: 0.3
                    shadowBlur: 10
                }

                DashboardContent {
                    id: contentCol
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 10
                }
            }
        }
    }
}