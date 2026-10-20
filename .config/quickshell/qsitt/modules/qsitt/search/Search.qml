pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.modules.common.theme
import qs.services
import qs.modules.common.widgets

Scope {
    id: root

    readonly property var searchService: SearchService
    function submit(): void { root.searchService.submit(); }

    function searchWithLens(): void {
        root.searchService.startLensSelection();
    }

    Variants {
        model: Quickshell.screens.filter(screen => SettingsService.targetScreens.length === 0 || SettingsService.targetScreens.includes(screen.name))

        PanelWindow {
            id: lensSelector

            required property var modelData

            property real startX: 0
            property real startY: 0
            property real currentX: 0
            property real currentY: 0

            screen: modelData
            visible: root.searchService.lensSelecting
            color: Theme.withAlpha(Theme.text, 0.4)
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            Rectangle {
                x: Math.min(lensSelector.startX, lensSelector.currentX)
                y: Math.min(lensSelector.startY, lensSelector.currentY)
                width: Math.abs(lensSelector.currentX - lensSelector.startX)
                height: Math.abs(lensSelector.currentY - lensSelector.startY)
                visible: lensSelectionArea.pressed
                color: Theme.withAlpha(Theme.primary, 0.2)
                border.color: Theme.primary
                border.width: 3
            }

            Text {
            font.family: Theme.fontFamily
                anchors {
                    top: parent.top
                    topMargin: 32
                    horizontalCenter: parent.horizontalCenter
                }
                text: "Google Lensで検索する範囲をドラッグ • 右クリックでキャンセル"
                color: Theme.primaryText
                font.pixelSize: Theme.fontSizeBody
                font.weight: Font.DemiBold
                style: Text.Outline
                styleColor: "#80000000"
            }

            MouseArea {
                id: lensSelectionArea

                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.CrossCursor

                onPressed: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        root.searchService.cancelLensSelection();
                        return;
                    }

                    lensSelector.startX = mouse.x;
                    lensSelector.startY = mouse.y;
                    lensSelector.currentX = mouse.x;
                    lensSelector.currentY = mouse.y;
                }

                onPositionChanged: mouse => {
                    if (pressed && pressedButtons & Qt.LeftButton) {
                        lensSelector.currentX = mouse.x;
                        lensSelector.currentY = mouse.y;
                    }
                }

                onReleased: mouse => {
                    if (mouse.button !== Qt.LeftButton)
                        return;

                    const x = Math.round(Math.min(lensSelector.startX, mouse.x) + (lensSelector.modelData.x || 0));
                    const y = Math.round(Math.min(lensSelector.startY, mouse.y) + (lensSelector.modelData.y || 0));
                    const width = Math.round(Math.abs(mouse.x - lensSelector.startX));
                    const height = Math.round(Math.abs(mouse.y - lensSelector.startY));

                    if (width < 4 || height < 4) {
                        root.searchService.cancelLensSelection();
                        return;
                    }

                    root.searchService.finishLensSelection(x + "," + y + " " + width + "x" + height);
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens.filter(screen => SettingsService.targetScreens.length === 0 || SettingsService.targetScreens.includes(screen.name))

        PanelWindow {
            id: searchWindow

            required property var modelData

            screen: modelData
            visible: root.searchService.visible
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            // Keep selection tools such as slurp visible above this persistent surface.
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: root.searchService.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            mask: Region {
                item: root.searchService.visible ? dismissLayer : null
            }

            Rectangle {
                id: dismissLayer

                anchors.fill: parent
                visible: root.searchService.visible
                color: Theme.withAlpha("#101820", 0.18)

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.searchService.close()
                }
            }

            FocusScope {
                id: focusScope

                anchors.fill: parent
                visible: root.searchService.visible
                focus: visible

                Keys.onEscapePressed: event => {
                    root.searchService.close();
                    event.accepted = true;
                }

                Rectangle {
                    id: searchContent

                    anchors {
                        top: parent.top
                        topMargin: Theme.barHeight + Theme.barOuterMargin + 12
                        horizontalCenter: parent.horizontalCenter
                    }

                    width: Math.min(650, parent.width - 32)
                    height: 64
                    radius: Theme.radiusLarge
                    color: Theme.surface
                    border.color: Theme.outline
                    border.width: 1

                    MouseArea {
                        anchors.fill: parent
                        onClicked: searchInput.forceActiveFocus()
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: Theme.spacing

                        QsIcon {
                            icon: Icons.search
                            size: 20
                            color: Theme.textSecondary
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: Theme.radius
                            color: Theme.surfaceContainer
                            border.color: searchInput.activeFocus ? Theme.primary : "transparent"
                            border.width: 1

                            Text {
            font.family: Theme.fontFamily
                                anchors {
                                    left: parent.left
                                    leftMargin: 12
                                    verticalCenter: parent.verticalCenter
                                }
                                visible: searchInput.text.length === 0
                                text: "Googleで検索"
                                color: Theme.textSecondary
                                font.pixelSize: Theme.fontSizeBody
                            }

                            TextInput {
                                id: searchInput

                                anchors {
                                    fill: parent
                                    leftMargin: 12
                                    rightMargin: 12
                                }
                                verticalAlignment: TextInput.AlignVCenter
                                text: root.searchService.query
                                color: Theme.text
                                selectionColor: Theme.primary
                                selectedTextColor: Theme.primaryText
                                font.pixelSize: Theme.fontSizeBody
                                focus: true
                                onTextChanged: root.searchService.query = text
                                onAccepted: root.submit()
                            }
                        }

                        Rectangle {
                            implicitWidth: 66
                            Layout.fillHeight: true
                            radius: Theme.radius
                            color: lensArea.containsMouse ? Theme.primary : Theme.primaryContainer

                            Text {
            font.family: Theme.fontFamily
                                anchors.centerIn: parent
                                text: "Lens"
                                color: lensArea.containsMouse ? Theme.primaryText : Theme.primary
                                font.pixelSize: Theme.fontSizeBody
                                font.weight: Font.DemiBold
                            }

                            MouseArea {
                                id: lensArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.searchWithLens()
                            }
                        }

                        Rectangle {
                            implicitWidth: 76
                            Layout.fillHeight: true
                            radius: Theme.radius
                            color: submitArea.containsMouse ? Theme.accent : Theme.primary

                            Text {
            font.family: Theme.fontFamily
                                anchors.centerIn: parent
                                text: "検索"
                                color: Theme.primaryText
                                font.pixelSize: Theme.fontSizeBody
                                font.weight: Font.DemiBold
                            }

                            MouseArea {
                                id: submitArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.submit()
                            }
                        }

                        Rectangle {
                            implicitWidth: 34
                            Layout.fillHeight: true
                            radius: Theme.radius
                            color: closeArea.containsMouse ? Theme.surfaceContainerHigh : Theme.surfaceContainer

                            QsIcon {
                                anchors.centerIn: parent
                                icon: Icons.x
                                size: 15
                                color: Theme.textSecondary
                            }

                            MouseArea {
                                id: closeArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.searchService.close()
                            }
                        }
                    }
                }
            }

            Connections {
                target: root.searchService

                function onVisibleChanged(): void {
                    if (root.searchService.visible)
                        Qt.callLater(() => searchInput.forceActiveFocus());
                }
            }
        }
    }

}
