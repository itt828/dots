pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as Controls
import QtQuick.Layouts
import qs.ui.theme
import qs.ui.widgets

ColumnLayout {
    id: root

    required property string label
    property alias text: field.text
    signal textEdited(string value)

    Layout.fillWidth: true
    spacing: 4

    QsSectionLabel {
        text: root.label
    }

    Controls.TextField {
        id: field

        Layout.fillWidth: true
        Layout.minimumWidth: 0
        implicitHeight: 34
        leftPadding: 9
        rightPadding: 9
        color: Theme.ink
        selectionColor: Theme.accent
        selectedTextColor: Theme.ink
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeBody
        Accessible.name: root.label
        onTextEdited: root.textEdited(text)

        background: Rectangle {
            radius: Theme.radiusSmall
            color: Theme.bgPrimary
            border.color: field.activeFocus ? Theme.focus : Theme.borderPrimary
            border.width: field.activeFocus ? 2 : 1
        }
    }
}
