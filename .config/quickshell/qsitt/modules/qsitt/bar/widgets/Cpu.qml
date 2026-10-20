import QtQuick
import qs.modules.common.widgets
import qs.modules.common.theme
import qs.services

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
        progressColor: Theme.text
        trackColor: Theme.outline
    }
}
