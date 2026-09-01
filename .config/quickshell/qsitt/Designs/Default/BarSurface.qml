pragma ComponentBehavior: Bound
import QtQuick
import "../../Assets"
import "../../Surfaces"
import "../../Widgets/Bar" as BarParts

Item {
    id: root
    required property var moduleContext

    BarParts.Base {
        implicitHeight: Theme.barHeight

        leftContent: BarModuleRow {
            spacing: Theme.barModuleSpacing
            moduleNames: Config.barLayout.left
            moduleContext: root.moduleContext
        }

        centerContent: BarModuleRow {
            spacing: Theme.barModuleSpacing
            moduleNames: Config.barLayout.center
            moduleContext: root.moduleContext
        }

        rightContent: BarModuleRow {
            spacing: Theme.barModuleSpacing
            moduleNames: Config.barLayout.right
            moduleContext: root.moduleContext
        }
    }
}
