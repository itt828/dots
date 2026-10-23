pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.modules.common.theme
import qs.modules.common.widgets
import qs.services

Scope {
    id: root

    readonly property var searchService: SearchService
    readonly property var categories: [
        { key: "all", label: "すべて" }, { key: "apps", label: "アプリ" },
        { key: "web", label: "Web / Lens" }, { key: "files", label: "ファイル" },
        { key: "tools", label: "ツール" }, { key: "clipboard", label: "クリップボード" }
    ]

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
            anchors { top: true; left: true; right: true; bottom: true }

            Rectangle {
                x: Math.min(lensSelector.startX, lensSelector.currentX)
                y: Math.min(lensSelector.startY, lensSelector.currentY)
                width: Math.abs(lensSelector.currentX - lensSelector.startX)
                height: Math.abs(lensSelector.currentY - lensSelector.startY)
                visible: lensArea.pressed
                color: Theme.withAlpha(Theme.primary, 0.2)
                border.color: Theme.primary
                border.width: 3
            }

            Text {
                anchors { top: parent.top; topMargin: 32; horizontalCenter: parent.horizontalCenter }
                text: "Google Lens: 範囲をドラッグ • 右クリックでキャンセル"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeBody
                color: Theme.primaryText
                style: Text.Outline
                styleColor: "#80000000"
            }

            MouseArea {
                id: lensArea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.CrossCursor
                onPressed: mouse => {
                    if (mouse.button === Qt.RightButton) { root.searchService.cancelLensSelection(); return; }
                    lensSelector.startX = mouse.x;
                    lensSelector.startY = mouse.y;
                    lensSelector.currentX = mouse.x;
                    lensSelector.currentY = mouse.y;
                }
                onPositionChanged: mouse => {
                    if (pressed && (pressedButtons & Qt.LeftButton)) {
                        lensSelector.currentX = mouse.x;
                        lensSelector.currentY = mouse.y;
                    }
                }
                onReleased: mouse => {
                    if (mouse.button !== Qt.LeftButton) return;
                    const x = Math.round(Math.min(lensSelector.startX, mouse.x) + (lensSelector.modelData.x || 0));
                    const y = Math.round(Math.min(lensSelector.startY, mouse.y) + (lensSelector.modelData.y || 0));
                    const width = Math.round(Math.abs(mouse.x - lensSelector.startX));
                    const height = Math.round(Math.abs(mouse.y - lensSelector.startY));
                    if (width < 4 || height < 4) { root.searchService.cancelLensSelection(); return; }
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
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: root.searchService.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            anchors { top: true; left: true; right: true; bottom: true }
            mask: Region { item: root.searchService.visible ? dismissLayer : null }

            Rectangle {
                id: dismissLayer
                anchors.fill: parent
                color: Theme.withAlpha("#101820", 0.25)
                MouseArea { anchors.fill: parent; onClicked: root.searchService.close() }
            }

            Rectangle {
                id: panel
                anchors { top: parent.top; topMargin: Theme.barHeight + Theme.barOuterMargin + 12; horizontalCenter: parent.horizontalCenter }
                width: Math.min(720, parent.width - 32)
                height: Math.min(630, parent.height - anchors.topMargin - 24)
                radius: Theme.radiusLarge
                color: Theme.surface
                border.color: Theme.outline
                border.width: 1
                clip: true

                MouseArea { anchors.fill: parent; onClicked: searchInput.forceActiveFocus() }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52
                        radius: Theme.radius
                        color: Theme.surfaceContainer
                        border.color: searchInput.activeFocus ? Theme.primary : Theme.outline
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10
                            QsIcon { icon: Icons.search; size: 20; color: Theme.textSecondary }
                            TextInput {
                                id: searchInput
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                verticalAlignment: TextInput.AlignVCenter
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeBody
                                selectionColor: Theme.primary
                                selectedTextColor: Theme.primaryText
                                text: root.searchService.query
                                focus: true
                                onTextChanged: { root.searchService.query = text; root.searchService.refresh(); }
                                onAccepted: root.searchService.submit()
                                Keys.onPressed: event => {
                                    if (event.key === Qt.Key_Escape) { root.searchService.close(); event.accepted = true; }
                                    else if (event.key === Qt.Key_Down) {
                                        if (root.searchService.results.length > 0) {
                                            root.searchService.selectedIndex = Math.min(root.searchService.selectedIndex + 1, root.searchService.results.length - 1);
                                            resultsView.positionViewAtIndex(root.searchService.selectedIndex, ListView.Contain);
                                        }
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Up) {
                                        root.searchService.selectedIndex = Math.max(0, root.searchService.selectedIndex - 1);
                                        resultsView.positionViewAtIndex(root.searchService.selectedIndex, ListView.Contain);
                                        event.accepted = true;
                                    } else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_6 && (event.modifiers & Qt.ControlModifier)) {
                                        root.searchService.setCategory(root.categories[event.key - Qt.Key_1].key);
                                        event.accepted = true;
                                    }
                                }
                            }
                        }
                        Text {
                            anchors { left: parent.left; leftMargin: 45; verticalCenter: parent.verticalCenter }
                            visible: searchInput.text.length === 0
                            text: "アプリ・ファイル・Web・ツールを検索"
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeBody
                            z: 1
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        Repeater {
                            model: root.categories
                            delegate: Rectangle {
                                required property var modelData
                                required property int index
                                implicitWidth: categoryText.implicitWidth + 20
                                implicitHeight: 30
                                radius: Theme.radiusSmall
                                color: root.searchService.category === modelData.key ? Theme.primaryContainer : categoryArea.containsMouse ? Theme.surfaceContainerHigh : "transparent"
                                Text {
                                    id: categoryText
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    color: root.searchService.category === modelData.key ? Theme.primary : Theme.textSecondary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                }
                                MouseArea {
                                    id: categoryArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { root.searchService.setCategory(parent.modelData.key); searchInput.forceActiveFocus(); }
                                }
                            }
                        }
                        Item { Layout.fillWidth: true }
                    }

                    ListView {
                        id: resultsView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 3
                        model: root.searchService.results
                        Text {
                            anchors.centerIn: parent
                            visible: root.searchService.results.length === 0
                            text: root.searchService.query.length > 0 ? "候補が見つかりません" : "検索語を入力してください"
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeBody
                        }
                        delegate: Rectangle {
                            required property var modelData
                            required property int index
                            width: resultsView.width
                            height: 54
                            radius: Theme.radiusSmall
                            color: root.searchService.selectedIndex === index ? Theme.primaryContainer : resultArea.containsMouse ? Theme.surfaceContainerHigh : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 10
                                Rectangle {
                                    Layout.preferredWidth: 34
                                    Layout.preferredHeight: 34
                                    radius: Theme.radiusSmall
                                    color: Theme.surfaceContainerHigh
                                    Image {
                                        id: appIcon
                                        anchors.centerIn: parent
                                        width: 25
                                        height: 25
                                        visible: modelData.kind === "app"
                                        source: visible ? Quickshell.iconPath(modelData.icon || "application-x-executable", "application-x-executable") : ""
                                        fillMode: Image.PreserveAspectFit
                                        asynchronous: true
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        visible: modelData.kind !== "app" || appIcon.status === Image.Error
                                        text: modelData.kind === "app" ? "A" : modelData.kind === "file" ? "F" : modelData.kind === "clipboard" ? "C" : modelData.kind === "tool" ? "T" : "W"
                                        color: Theme.primary
                                        font.family: Theme.fontFamily
                                        font.bold: true
                                    }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text { Layout.fillWidth: true; text: modelData.title; color: Theme.text; elide: Text.ElideRight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeBody }
                                    Text { Layout.fillWidth: true; text: modelData.subtitle; color: Theme.textSecondary; elide: Text.ElideMiddle; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                                }
                                Text { text: modelData.kind === "app" ? "アプリ" : modelData.kind === "file" ? "ファイル" : modelData.kind === "clipboard" ? "履歴" : modelData.kind === "tool" ? "ツール" : "Web"; color: Theme.textSecondary; font.pixelSize: Theme.fontSizeSmall }
                            }
                            MouseArea {
                                id: resultArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { root.searchService.selectedIndex = parent.index; root.searchService.activate(parent.modelData); }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "↑↓ 選択  •  Enter 実行  •  Ctrl+1〜6 カテゴリ  •  Esc 閉じる"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                        Item { Layout.fillWidth: true }
                        Text {
                            visible: root.searchService.category === "clipboard"
                            text: "履歴を消去"
                            color: Theme.primary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.searchService.clearClipboard() }
                        }
                    }
                }
            }

            Connections {
                target: root.searchService
                function onVisibleChanged(): void {
                    if (root.searchService.visible) Qt.callLater(() => searchInput.forceActiveFocus());
                }
            }
        }
    }
}
