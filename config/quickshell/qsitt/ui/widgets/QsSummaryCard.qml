import QtQuick
import QtQuick.Layouts
import qs.ui.theme

Rectangle {
    id: root

    required property string title
    required property string subtitle
    property string icon: ""
    property bool active: false
    property bool compact: false
    signal clicked

    Layout.fillWidth: true
    Layout.preferredWidth: 1
    implicitHeight: compact ? Math.max(76, content.implicitHeight + 32) : Math.max(132, content.implicitHeight + 32)
    radius: 14
    color: {
        if (!enabled)
            return Theme.disabled;
        if (area.pressed)
            return active ? Theme.accentPressed : Theme.pressed;
        if (area.containsMouse)
            return active ? Theme.accent : Theme.hover;
        return active ? Theme.mustard200 : Theme.bgTertiary;
    }
    border.color: activeFocus ? Theme.focus : Theme.borderPrimary
    border.width: activeFocus ? 2 : 1
    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: title
    Accessible.description: subtitle
    Accessible.onPressAction: if (enabled)
        clicked()

    GridLayout {
        id: content
        columns: 3
        columnSpacing: 8
        rowSpacing: 8
        anchors {
            top: root.compact ? undefined : parent.top
            verticalCenter: root.compact ? parent.verticalCenter : undefined
            left: parent.left
            right: parent.right
            margins: 16
        }

        QsIcon {
            icon: root.icon
            size: 20
            color: root.enabled ? Theme.ink : Theme.disabledInk
            Layout.row: 0
            Layout.column: 0
        }

        ColumnLayout {
            Layout.row: root.compact ? 0 : 1
            Layout.column: root.compact ? 1 : 0
            Layout.columnSpan: root.compact ? 1 : 3
            Layout.fillWidth: true
            spacing: root.compact ? 4 : 8

            Text {
                Layout.fillWidth: true
                text: root.title
                color: root.enabled ? Theme.ink : Theme.disabledInk
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeBody
                font.weight: Font.Medium
                wrapMode: Text.Wrap
            }
            QsMarqueeText {
                Layout.fillWidth: true
                text: root.subtitle
                color: root.enabled ? Theme.textSecondary : Theme.disabledInk
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                maximumLineCount: 2
                wrapMode: Text.Wrap
            }
        }

        QsIcon {
            Layout.row: 0
            Layout.column: 2
            Layout.alignment: Qt.AlignRight
            icon: Icons.caretRight
            size: 20
            color: root.enabled ? Theme.ink : Theme.disabledInk
        }

        Item {
            visible: !root.compact
            Layout.row: 0
            Layout.column: 1
            Layout.fillWidth: true
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
    Keys.onReturnPressed: clicked()
    Keys.onSpacePressed: clicked()
}
