import qs.ui.theme
import qs.ui.widgets

QsButton {
    id: root

    required property var powerService
    required property string outputName

    icon: Icons.power
    variant: QsButton.Ghost
    toolTip: "電源"
    onClicked: powerService.toggleAt(outputName, root)
}
