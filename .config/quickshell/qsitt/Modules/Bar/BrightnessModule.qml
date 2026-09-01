import QtQuick
import "../../Widgets/Bar" as BarParts

Item {
    id: root
    required property var moduleContext

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    BarParts.Brightness {
        id: content
        anchors.centerIn: parent
        brightnessService: root.moduleContext.services.brightness
    }
}
