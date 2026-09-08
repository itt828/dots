import QtQuick
import qs.Widgets
import qs.Common
import qs.Services

Item {
    id: root
    implicitWidth: display.implicitWidth
    implicitHeight: display.implicitHeight
    width: implicitWidth
    height: implicitHeight

    required property var memoryService

    QsBarValue {
        id: display
        value: memoryService.usage
        iconName: Icons.memory
        showLabel: true
        labelText: memoryService.label
        progressColor: "black"
        trackColor: "#aaaaaa"
    }
}
