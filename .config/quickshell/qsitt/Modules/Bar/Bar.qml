pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.Common

Scope {
    id: root

    Variants {
        model: Quickshell.screens.filter(screen => SettingsData.targetScreens.length === 0 || SettingsData.targetScreens.includes(screen.name))

        PanelWindow {
            id: barWindow
            required property var modelData

            screen: modelData
            color: "transparent"
            implicitHeight: Theme.barHeight + Theme.barOuterMargin

            anchors {
                top: true
                left: true
                right: true
            }

            BarContext {
                id: moduleContext
                hostWindow: barWindow
                targetScreen: barWindow.screen
            }

            Loader {
                id: designLoader
                anchors.fill: parent

                Component.onCompleted: designLoader.setSource(BarDesignRegistry.barSourceFor(SettingsData.barDesign), {
                    "moduleContext": moduleContext
                })
            }
        }
    }
}
