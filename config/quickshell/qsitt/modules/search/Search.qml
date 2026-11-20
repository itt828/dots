pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Wayland
import qs.ui.theme
import qs.ui.widgets
import qs.services

Scope {
    id: root

    readonly property var searchService: SearchService
    readonly property var categories: SearchService.scopes
    readonly property var categoryShortcuts: ["all", "apps", "web", "files", "tools", "clipboard", "calc"]

    function resultIcon(kind: string, value: string): string {
        if (kind === "scope")
            kind = ({
                    apps: "app",
                    files: "file",
                    tools: "tool",
                    calc: "calculation"
                })[value] ?? value;
        return ({
                app: Icons.applications,
                file: Icons.folder,
                tool: Icons.cpu,
                calculation: Icons.calculator,
                clipboard: Icons.clipboard,
                "clipboard-image": Icons.clipboard,
                "clipboard-file": Icons.clipboard
            })[kind] ?? Icons.globe;
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: lensSelector
            required property var modelData
            property real startX: 0
            property real startY: 0
            property real currentX: 0
            property real currentY: 0

            screen: modelData
            visible: root.searchService.lensSelecting
            color: Theme.withAlpha(Theme.textPrimary, 0.4)
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
                visible: lensArea.pressed
                color: Theme.withAlpha(Theme.mustard800, 0.2)
                border.color: Theme.mustard800
                border.width: 3
            }

            Text {
                anchors {
                    top: parent.top
                    topMargin: 32
                    horizontalCenter: parent.horizontalCenter
                }
                text: "Google Lens: 範囲をドラッグ • 右クリックでキャンセル"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeBody
                color: Theme.surface
                style: Text.Outline
                styleColor: "#80000000"
            }

            MouseArea {
                id: lensArea
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
                    if (pressed && (pressedButtons & Qt.LeftButton)) {
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
        model: Quickshell.screens

        PanelWindow {
            id: searchWindow
            required property var modelData
            readonly property bool hasBar: SettingsService.targetScreens.length === 0 || SettingsService.targetScreens.includes(modelData.name)

            screen: modelData
            // Item.visible also reflects its parent window's visibility.
            // Use the popup state directly so a hidden window can open again.
            visible: panel.shown || panel.reveal > 0
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "qsitt:search"
            BackgroundEffect.blurRegion: Region {
                item: panel.blurActive ? panel : null
                radius: Theme.radiusLarge
            }
            WlrLayershell.keyboardFocus: panel.shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }
            mask: Region {
                item: panel.shown ? dismissLayer : null
            }

            Rectangle {
                id: dismissLayer
                anchors.fill: parent
                anchors.topMargin: searchWindow.hasBar ? Theme.barHeight : 0
                color: Theme.glassScrim
                opacity: panel.progress
                enabled: panel.shown
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.searchService.close()
                }
            }

            QsWindowShadow {
                surface: panel
            }

            QsPopupSurface {
                id: panel
                shown: root.searchService.visible && searchWindow.modelData.name === root.searchService.focusedOutputName
                transformOrigin: Item.Top
                entryX: 0
                entryY: -20
                closedScale: 0.96
                property real resultsHeight: 72

                function updateResultsHeight(): void {
                    if (!shown || root.searchService.searching)
                        return;
                    const rows = root.searchService.results;
                    resultsHeight = Math.min(420, Math.max(72, rows.reduce((sum, row) => sum + (row.preview ? 91 : 54), 0)));
                }

                onShownChanged: if (shown)
                    Qt.callLater(updateResultsHeight)
                onRevealChanged: if (!shown && reveal <= 0)
                    resultsHeight = 72

                Behavior on height {
                    enabled: panel.shown && panel.progress >= 0.99
                    QsNumberAnimation {}
                }

                Connections {
                    target: root.searchService
                    function onResultsChanged(): void {
                        Qt.callLater(panel.updateResultsHeight);
                    }
                    function onSearchingChanged(): void {
                        if (!root.searchService.searching)
                            Qt.callLater(panel.updateResultsHeight);
                    }
                }
                anchors {
                    top: parent.top
                    topMargin: Theme.belowBar + 42
                    horizontalCenter: parent.horizontalCenter
                }
                width: Math.min(664, searchWindow.modelData.width - 32)
                height: Math.max(1, Math.min(searchWindow.modelData.height - anchors.topMargin - 24, 152 + resultsHeight))
                radius: Theme.radiusLarge
                color: Theme.surface
                border.color: Theme.glassOutline
                border.width: 1
                clip: true

                MouseArea {
                    anchors.fill: parent
                    onClicked: searchInput.forceActiveFocus()
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52
                        radius: Theme.radius
                        color: Theme.bgSecondary
                        border.color: searchInput.activeFocus ? Theme.mustard800 : Theme.border
                        border.width: 1
                        Behavior on border.color {
                            QsColorAnimation {}
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10
                            QsIcon {
                                icon: Icons.search
                                size: 20
                                color: Theme.textSecondary
                            }
                            TextInput {
                                id: searchInput
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                verticalAlignment: TextInput.AlignVCenter
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeBody
                                selectionColor: Theme.mustard800
                                selectedTextColor: Theme.surface
                                text: root.searchService.query
                                focus: true
                                onTextEdited: root.searchService.query = text
                                onAccepted: if (!searchInput.inputMethodComposing)
                                    root.searchService.submit()
                                Keys.onPressed: event => {
                                    if (searchInput.inputMethodComposing)
                                        return;
                                    if (event.key === Qt.Key_Escape) {
                                        root.searchService.close();
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Down) {
                                        if (root.searchService.results.length > 0) {
                                            root.searchService.selectedIndex = (root.searchService.selectedIndex + 1) % root.searchService.results.length;
                                            resultsView.positionViewAtIndex(root.searchService.selectedIndex, ListView.Contain);
                                        }
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Up) {
                                        const count = root.searchService.results.length;
                                        if (count > 0) {
                                            root.searchService.selectedIndex = (root.searchService.selectedIndex + count - 1) % count;
                                            resultsView.positionViewAtIndex(root.searchService.selectedIndex, ListView.Contain);
                                        }
                                        event.accepted = true;
                                    } else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_7 && (event.modifiers & Qt.ControlModifier)) {
                                        root.searchService.setCategory(root.categoryShortcuts[event.key - Qt.Key_1]);
                                        event.accepted = true;
                                    }
                                }
                            }
                        }
                        Text {
                            anchors {
                                left: parent.left
                                leftMargin: 45
                                verticalCenter: parent.verticalCenter
                            }
                            visible: searchInput.text.length === 0
                            text: "アプリ・ツール・ファイルを検索"
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeBody
                            z: 1
                        }
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 5
                        Repeater {
                            model: root.categories
                            delegate: Rectangle {
                                required property var modelData
                                required property int index
                                implicitWidth: categoryText.implicitWidth + (panel.width < 525 ? 8 : 16)
                                implicitHeight: 27
                                radius: 7
                                color: root.searchService.category === modelData.key ? Theme.mustard200 : categoryArea.containsMouse ? Theme.hover : Theme.bgTertiary
                                scale: categoryArea.pressed ? 0.96 : 1
                                Behavior on scale {
                                    QsNumberAnimation {
                                        duration: Theme.motionFast
                                    }
                                }
                                Text {
                                    id: categoryText
                                    anchors.centerIn: parent
                                    text: modelData.prefix ? modelData.prefix + "  " + modelData.label : modelData.label
                                    color: root.searchService.category === modelData.key ? Theme.mustard800 : Theme.textSecondary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                }
                                MouseArea {
                                    id: categoryArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.searchService.setCategory(parent.modelData.key);
                                        searchInput.forceActiveFocus();
                                    }
                                }
                            }
                        }
                    }

                    ListView {
                        id: resultsView

                        currentIndex: count > 0 ? root.searchService.selectedIndex : -1
                        highlightMoveDuration: Theme.motionFast
                        highlightResizeDuration: Theme.motionFast
                        highlightMoveVelocity: -1
                        highlightResizeVelocity: -1
                        highlight: Rectangle {
                            radius: 12
                            color: Theme.mustard200
                            z: 0
                        }

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 3
                        model: root.searchService.results
                        Controls.ScrollBar.vertical: Controls.ScrollBar {
                            policy: Controls.ScrollBar.AsNeeded
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: root.searchService.results.length === 0
                            text: root.searchService.searching ? "検索中…" : root.searchService.category === "calc" ? "例: = (128 + 32) / 2" : root.searchService.query.length > 0 ? "候補が見つかりません" : "登録済みのアプリ・ツールがありません"
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeBody
                        }
                        delegate: Rectangle {
                            required property var modelData
                            required property int index
                            width: resultsView.width
                            height: modelData.preview ? 88 : 51
                            radius: 12
                            color: root.searchService.selectedIndex !== index && resultArea.containsMouse ? Theme.hover : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 10
                                Rectangle {
                                    Layout.preferredWidth: 34
                                    Layout.preferredHeight: 34
                                    visible: !modelData.preview
                                    radius: 12
                                    color: Theme.hover
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
                                    QsIcon {
                                        anchors.centerIn: parent
                                        visible: modelData.kind !== "app" || appIcon.status === Image.Error
                                        icon: root.resultIcon(modelData.kind, modelData.value)
                                        size: 18
                                        color: Theme.mustard800
                                    }
                                }
                                Rectangle {
                                    Layout.preferredWidth: 100
                                    Layout.preferredHeight: 70
                                    visible: !!modelData.preview
                                    radius: 12
                                    color: Theme.hover
                                    clip: true
                                    Image {
                                        anchors.fill: parent
                                        source: modelData.preview || ""
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                    }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    QsMarqueeText {
                                        Layout.fillWidth: true
                                        text: modelData.title
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeBody
                                    }
                                    QsMarqueeText {
                                        Layout.fillWidth: true
                                        text: modelData.subtitle
                                        color: Theme.textSecondary
                                        elideMode: Text.ElideMiddle
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeSmall
                                    }
                                }
                                Text {
                                    text: modelData.kind === "scope" ? "絞り込み" : modelData.kind === "calculation" ? "コピー" : modelData.kind === "app" ? "アプリ" : modelData.kind === "file" ? "ファイル" : modelData.kind === "clipboard" ? "履歴" : modelData.kind === "clipboard-image" ? "画像" : modelData.kind === "clipboard-file" ? "メディア" : modelData.kind === "tool" ? "ツール" : "Web"
                                    color: Theme.textSecondary
                                    font.pixelSize: Theme.fontSizeSmall
                                }
                            }
                            MouseArea {
                                id: resultArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.searchService.selectedIndex = parent.index;
                                    root.searchService.activate(parent.modelData);
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "↑↓ 選択   Enter 実行   / 絞り込み一覧   Esc 閉じる"
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        Text {
                            visible: root.searchService.category === "clipboard"
                            text: "履歴を消去"
                            color: Theme.mustard800
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.searchService.clearClipboard()
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
