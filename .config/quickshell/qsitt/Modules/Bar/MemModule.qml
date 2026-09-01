import QtQuick
import "../../Widgets/Bar" as BarParts

Item {
    id: root
    required property var moduleContext

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    BarParts.Mem {
        id: content
        anchors.centerIn: parent
        memService: root.moduleContext.services.mem
    }
}
