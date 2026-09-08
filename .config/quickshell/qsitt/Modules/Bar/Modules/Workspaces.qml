import QtQuick
import qs.Modules.Bar.Widgets as BarParts
import qs.Services

Item {
    id: root
    required property var moduleContext

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    BarParts.Workspaces {
        id: content
        anchors.centerIn: parent
        workspaceService: WorkspaceService
        outputName: root.moduleContext.targetScreen.name
        showOtherOutputs: true
    }
}
