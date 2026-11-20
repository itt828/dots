pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as Controls
import qs.ui.theme

Controls.ComboBox {
    id: root

    implicitWidth: 120
    implicitHeight: 32
    hoverEnabled: true
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSizeSmall
    leftPadding: 8
    rightPadding: 26
    topPadding: 3
    bottomPadding: 3
    onEnabledChanged: if (!enabled && popup.visible)
        popup.close()

    background: Rectangle {
        color: root.hovered ? Theme.hover : Theme.bgTertiary
        radius: 7
        border.color: root.activeFocus ? Theme.focus : Theme.borderPrimary
        border.width: root.activeFocus ? 2 : 1
    }

    contentItem: QsMarqueeText {
        text: root.displayText
        font: root.font
        color: root.enabled ? Theme.ink : Theme.disabledInk
        hovered: root.hovered && !root.popup.visible
    }

    indicator: QsIcon {
        icon: Icons.caretDown
        size: 12
        color: Theme.muted
        x: root.width - width - 7
        y: Math.round((root.height - height) / 2)
    }

    delegate: Controls.ItemDelegate {
        id: option

        required property int index

        width: root.popup.availableWidth
        height: 32
        hoverEnabled: true
        highlighted: root.highlightedIndex === index
        text: root.textAt(index)
        horizontalPadding: 8
        verticalPadding: 4

        background: Rectangle {
            radius: 5
            color: option.highlighted || option.hovered ? Theme.hover : option.index === root.currentIndex ? Theme.mustard200 : Theme.bgSecondary
        }

        contentItem: QsMarqueeText {
            text: option.text
            font: root.font
            color: Theme.ink
            hovered: option.hovered
        }
    }

    popup: Controls.Popup {
        y: root.height + 3
        width: root.width
        height: Math.min(224, choices.contentHeight + padding * 2)
        padding: 3
        margins: 8

        background: Rectangle {
            radius: 7
            color: Theme.bgSecondary
            border.color: Theme.borderPrimary
        }

        contentItem: ListView {
            id: choices
            clip: true
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex
            boundsBehavior: Flickable.StopAtBounds
            Controls.ScrollIndicator.vertical: Controls.ScrollIndicator {}
        }
    }
}
