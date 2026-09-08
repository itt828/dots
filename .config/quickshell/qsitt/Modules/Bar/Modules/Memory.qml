import QtQuick
import qs.Modules.Bar.Widgets as BarParts
import qs.Services

Item {
    id: root
    required property var moduleContext

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    BarParts.Memory {
        id: content
        anchors.centerIn: parent
        memoryService: MemoryService
    }
}
