pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    required property var moduleContext
    required property var moduleNames

    Repeater {
        model: root.moduleNames
        delegate: BarModuleSlot {
            required property string modelData
            moduleName: modelData
            moduleContext: root.moduleContext
        }
    }
}
