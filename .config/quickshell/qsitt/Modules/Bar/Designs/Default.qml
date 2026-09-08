pragma ComponentBehavior: Bound
import QtQuick
import qs.Common
import ".."
import qs.Modules.Bar.Widgets as BarParts

Item {
    id: root
    required property var moduleContext

    BarParts.Base {
        implicitHeight: Theme.barHeight

        leftContent: BarModuleRow {
            spacing: Theme.barModuleSpacing
            moduleNames: SettingsData.barLayout.left
            moduleContext: root.moduleContext
        }

        centerContent: BarModuleRow {
            spacing: Theme.barModuleSpacing
            moduleNames: SettingsData.barLayout.center
            moduleContext: root.moduleContext
        }

        rightContent: BarModuleRow {
            spacing: Theme.barModuleSpacing
            moduleNames: SettingsData.barLayout.right
            moduleContext: root.moduleContext
        }
    }
}
