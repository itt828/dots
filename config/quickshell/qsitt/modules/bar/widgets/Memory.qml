import QtQuick
import qs.ui.widgets
import qs.ui.theme
import qs.services

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
        iconName: Icons.ram
        showLabel: true
        labelText: memoryService.label
        progressColor: Theme.textPrimary
        trackColor: Theme.border
    }
}
