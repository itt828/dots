import QtQuick
import qs.ui.theme

Rectangle {
    id: root

    enum Variant {
        Secondary,
        Primary,
        Ghost,
        Destructive
    }

    property string text: ""
    property string icon: ""
    property string toolTip: ""
    property bool checkable: false
    property bool highlighted: false
    property int horizontalPadding: 16
    property int labelSize: Theme.fontSizeBody
    property int variant: QsButton.Secondary
    property color highlightColor: Theme.accent
    signal clicked

    readonly property bool iconOnly: text === "" && icon !== ""
    readonly property bool primary: highlighted || variant === QsButton.Primary
    readonly property bool destructive: variant === QsButton.Destructive

    implicitWidth: iconOnly ? 36 : content.implicitWidth + horizontalPadding * 2
    implicitHeight: 36
    radius: 6
    scale: Theme.motionEnabled && area.pressed ? 0.96 : 1
    color: !enabled ? Theme.disabled : destructive ? Theme.error : primary ? highlightColor : variant === QsButton.Ghost ? "transparent" : Theme.subtle
    border.width: activeFocus ? 2 : (variant === QsButton.Secondary && !primary && !iconOnly && enabled ? 1 : 0)
    border.color: activeFocus ? Theme.focus : Theme.border
    activeFocusOnTab: true
    Accessible.role: checkable ? Accessible.CheckBox : Accessible.Button
    Accessible.name: text || toolTip
    Accessible.checkable: checkable
    Accessible.checked: checkable && highlighted
    Accessible.onPressAction: if (root.enabled)
        root.clicked()
    Accessible.onToggleAction: if (root.enabled)
        root.clicked()

    QsHoverBackground {
        hovered: root.enabled && area.containsMouse
        radius: root.radius
        anchors.margins: root.border.width
        color: root.destructive ? Theme.withAlpha(Theme.surface, 0.14) : root.primary ? Theme.withAlpha(Theme.ink, 0.07) : Theme.hover
    }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 8

        QsIcon {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon !== ""
            icon: root.icon
            size: 20
            color: label.color
        }
        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            visible: root.text !== ""
            text: root.text
            color: !root.enabled ? Theme.disabledInk : root.destructive ? Theme.surface : Theme.ink
            font.family: Theme.fontFamily
            font.pixelSize: root.labelSize
            font.weight: Font.Medium
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
    Keys.onSpacePressed: clicked()
    Keys.onReturnPressed: clicked()

    QsToolTip {
        text: root.toolTip
        hovered: root.toolTip !== "" && area.containsMouse
    }
    Behavior on scale {
        QsNumberAnimation {
            duration: Theme.motionFast
        }
    }
}
