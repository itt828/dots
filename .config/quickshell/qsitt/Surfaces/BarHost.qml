pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import "../Assets"
import "../Core"

Scope {
    id: root
    required property var services

    Variants {
        model: Quickshell.screens.filter((screen, index) => {
            if (Config.targetScreens.length > 0)
                return Config.targetScreens.includes(screen.name);
            return index === 0;
        })

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

            ModuleContext {
                id: moduleContext
                services: root.services
                hostWindow: barWindow
                targetScreen: barWindow.screen
            }

            Loader {
                id: designLoader
                anchors.fill: parent

                Component.onCompleted: designLoader.setSource(DesignRegistry.barSourceFor(Config.barDesign), {
                    "moduleContext": moduleContext
                })
            }
        }
    }
}
