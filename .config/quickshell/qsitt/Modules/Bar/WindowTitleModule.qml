import QtQuick
import "../../Widgets/Bar" as BarParts

Item {
    id: root
    required property var moduleContext

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    BarParts.WindowTitle {
        id: content
        anchors.centerIn: parent
        windowService: root.moduleContext.services.windows
    }
}
