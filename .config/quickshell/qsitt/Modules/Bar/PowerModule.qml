import QtQuick
import "../../Widgets/Bar" as BarParts

Item {
    id: root
    required property var moduleContext

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    BarParts.PowerButton {
        id: content
        anchors.centerIn: parent
        powerContext: root.moduleContext.services.power
    }
}
