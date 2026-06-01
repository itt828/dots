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

    BarValue {
        id: display
        value: CpuService.usage
        iconName: FontIcons.cpu
        showLabel: true
        labelText: CpuService.label
        progressColor: "black"
        trackColor: "#aaaaaa"
    }
}
