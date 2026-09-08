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

    required property var cpuService

    QsBarValue {
        id: display
        value: cpuService.usage
        iconName: Icons.cpu
        showLabel: true
        labelText: cpuService.label
        progressColor: "black"
        trackColor: "#aaaaaa"
    }
}
