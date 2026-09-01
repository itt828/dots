import QtQuick
import "../../Widgets/Bar" as BarParts

Item {
    id: root
    required property var moduleContext

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    BarParts.Tray {
        id: content
        anchors.centerIn: parent
        rootWindow: root.moduleContext.hostWindow
    }
}
