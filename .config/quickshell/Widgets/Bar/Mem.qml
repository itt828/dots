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

    required property var memService

    BarValue {
        id: display
        value: memService.usage
        iconName: FontIcons.memory
        showLabel: true
        labelText: memService.label
        progressColor: "black"
        trackColor: "#aaaaaa"
    }
}
