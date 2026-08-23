import QtQuick
import "../../Components"
import "../../Assets"
import "../../Services"

Item {
    id: root
    implicitWidth: display.implicitWidth
    implicitHeight: display.implicitHeight
    width: implicitWidth
    height: implicitHeight

    required property var cpuService

    BarValue {
        id: display
        value: cpuService.usage
        iconName: FontIcons.cpu
        showLabel: true
        labelText: cpuService.label
        progressColor: "black"
        trackColor: "#aaaaaa"
    }
}
