pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.ui.theme
import qs.ui.widgets

PopupWindow {
    id: root

    property SystemTrayItem trayItem: null
    property var submenuPath: []
    readonly property QsMenuEntry currentSubmenu: submenuPath[submenuPath.length - 1] ?? null

    grabFocus: true
    color: "transparent"
    implicitWidth: 250
    implicitHeight: content.implicitHeight + 12
    anchor {
        edges: Edges.Bottom | Edges.Right
        gravity: Edges.Bottom | Edges.Left
        margins.bottom: -5
    }
    mask: Region {
        item: surface
        radius: surface.radius
    }

    onVisibleChanged: {
        if (visible) {
            entries.currentIndex = -1;
            entries.forceActiveFocus();
        } else {
            submenuPath = [];
        }
    }

    onTrayItemChanged: if (!trayItem)
        visible = false

    function openFor(tile: Item, item: SystemTrayItem): void {
        visible = false;
        anchor.item = tile;
        trayItem = item;
        // Let the previous Wayland popup release its grab before showing again.
        Qt.callLater(showAtAnchor);
    }

    function showAtAnchor(): void {
        if (anchor.item?.visible && trayItem?.hasMenu)
            visible = true;
    }

    function activate(entry: QsMenuEntry): void {
        if (!entry?.enabled || entry.isSeparator)
            return;
        if (entry.hasChildren) {
            submenuPath = [...submenuPath, entry];
        } else {
            entry.triggered();
            visible = false;
        }
    }

    function goBack(): void {
        submenuPath = submenuPath.slice(0, -1);
        entries.forceActiveFocus();
    }

    QsMenuOpener {
        id: mainMenu
        menu: root.visible ? root.trayItem?.menu ?? null : null
    }

    QsMenuOpener {
        id: submenu
        menu: root.visible ? root.currentSubmenu : null
    }

    Rectangle {
        id: surface

        anchors.fill: parent
        color: Theme.surface
        radius: 12
        border.color: Theme.borderPrimary
        border.width: 1

        ColumnLayout {
            id: content

            anchors.fill: parent
            anchors.margins: 6
            spacing: 4

            QsButton {
                Layout.fillWidth: true
                visible: root.currentSubmenu !== null
                implicitHeight: 32
                text: "‹  戻る"
                variant: QsButton.Ghost
                onClicked: root.goBack()
            }

            ListView {
                id: entries

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: Math.min(320, Math.max(34, contentHeight))
                clip: true
                model: root.currentSubmenu ? submenu.children : mainMenu.children
                boundsBehavior: Flickable.StopAtBounds
                keyNavigationEnabled: false
                focus: true
                Controls.ScrollIndicator.vertical: Controls.ScrollIndicator {}

                onModelChanged: {
                    currentIndex = -1;
                    positionViewAtBeginning();
                }

                function moveSelection(step: int): void {
                    const choices = model.values;
                    let index = currentIndex < 0 && step < 0 ? choices.length : currentIndex;
                    for (let remaining = choices.length; remaining > 0; remaining--) {
                        index = (index + step + choices.length) % choices.length;
                        const entry = choices[index];
                        if (entry?.enabled && !entry.isSeparator) {
                            currentIndex = index;
                            positionViewAtIndex(index, ListView.Contain);
                            return;
                        }
                    }
                }

                Keys.onDownPressed: moveSelection(1)
                Keys.onUpPressed: moveSelection(-1)
                Keys.onLeftPressed: if (root.currentSubmenu)
                    root.goBack()
                Keys.onRightPressed: if (currentItem?.modelData?.hasChildren)
                    root.activate(currentItem.modelData)
                Keys.onReturnPressed: root.activate(currentItem?.modelData ?? null)
                Keys.onEnterPressed: root.activate(currentItem?.modelData ?? null)
                Keys.onSpacePressed: root.activate(currentItem?.modelData ?? null)
                Keys.onEscapePressed: root.visible = false

                delegate: Controls.ItemDelegate {
                    id: option

                    required property QsMenuEntry modelData
                    readonly property bool separator: modelData?.isSeparator ?? false
                    readonly property int buttonType: modelData?.buttonType ?? QsMenuButtonType.None
                    readonly property int checkState: modelData?.checkState ?? Qt.Unchecked
                    readonly property bool radio: buttonType === QsMenuButtonType.RadioButton
                    readonly property bool hasCheck: buttonType !== QsMenuButtonType.None
                    readonly property bool marked: checkState !== Qt.Unchecked

                    width: ListView.view?.width ?? 0
                    height: separator ? 9 : 34
                    leftPadding: 10
                    rightPadding: 10
                    enabled: (modelData?.enabled ?? false) && !separator
                    hoverEnabled: true
                    highlighted: ListView.isCurrentItem
                    text: modelData?.text ?? ""
                    Accessible.ignored: !modelData || separator
                    Accessible.role: hasCheck ? (radio ? Accessible.RadioButton : Accessible.CheckBox) : Accessible.MenuItem
                    Accessible.name: text
                    Accessible.checkable: hasCheck
                    Accessible.checked: marked
                    onClicked: root.activate(modelData)

                    background: Rectangle {
                        radius: Theme.radiusSmall
                        color: option.enabled && (option.hovered || option.highlighted || option.activeFocus) ? Theme.hover : "transparent"
                    }

                    contentItem: RowLayout {
                        visible: option.modelData !== null && !option.separator
                        spacing: 8

                        Image {
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                            visible: status === Image.Ready
                            source: {
                                const icon = option.modelData?.icon ?? "";
                                const prefix = "image://icon/";
                                return icon.startsWith(prefix) && !icon.includes("?") ? Quickshell.iconPath(icon.slice(prefix.length), true) : icon;
                            }
                            sourceSize.width: 16
                            sourceSize.height: 16
                            fillMode: Image.PreserveAspectFit
                            opacity: option.enabled ? 1 : 0.5
                        }

                        Text {
                            Layout.fillWidth: true
                            text: option.text
                            textFormat: Text.PlainText
                            elide: Text.ElideRight
                            color: option.enabled ? Theme.ink : Theme.disabledInk
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeBody
                        }

                        Text {
                            visible: option.hasCheck
                            text: option.radio ? (option.marked ? "◉" : "○") : option.checkState === Qt.PartiallyChecked ? "⊟" : option.marked ? "☑" : "☐"
                            color: option.enabled ? (option.marked ? Theme.mustard800 : Theme.muted) : Theme.disabledInk
                            font.pixelSize: 16
                        }

                        QsIcon {
                            visible: option.modelData?.hasChildren ?? false
                            icon: Icons.caretRight
                            size: 14
                            color: option.enabled ? Theme.muted : Theme.disabledInk
                        }
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        visible: option.separator
                        height: 1
                        color: Theme.borderPrimary
                    }
                }
            }
        }
    }
}
