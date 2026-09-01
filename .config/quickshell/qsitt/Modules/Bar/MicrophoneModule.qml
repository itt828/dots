import QtQuick
import "../../Widgets/Bar" as BarParts

Item {
    id: root
    required property var moduleContext

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    BarParts.Microphone {
        id: content
        anchors.centerIn: parent
        volumeService: root.moduleContext.services.volume
    }
}
