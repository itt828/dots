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
        value: MemService.usage
        iconName: FontIcons.ram
        showLabel: true
        labelText: MemService.label
        progressColor: "black"
        trackColor: "#aaaaaa"
    }
}
