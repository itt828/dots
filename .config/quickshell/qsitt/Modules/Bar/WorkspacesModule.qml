import QtQuick
import "../../Widgets/Bar" as BarParts

Item {
    id: root
    required property var moduleContext

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    BarParts.Workspaces {
        id: content
        anchors.centerIn: parent
        workspaceStore: root.moduleContext.services.workspaces
        outputName: root.moduleContext.targetScreen.name
        showOtherOutputs: true
    }
}
