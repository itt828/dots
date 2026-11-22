pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.services
import qs.ui.theme
import qs.ui.widgets

FloatingWindow {
    id: root

    readonly property int tokensCategory: 7
    property int category: 0

    title: "kalumiru UI ギャラリー"
    visible: true
    color: Theme.bgPrimary
    implicitWidth: 800
    implicitHeight: 620
    minimumSize: Qt.size(500, 320)
    onClosed: visible = false

    IpcHandler {
        target: "debug-ui"

        function isOpen(): bool {
            return root.visible;
        }

        function open(): void {
            root.visible = true;
        }

        function openTokens(): void {
            root.category = root.tokensCategory;
            gallery.contentY = 0;
            root.visible = true;
            navigation.contentY = Math.max(0, navigation.contentHeight - navigation.height);
        }

        function close(): void {
            root.visible = false;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 4

                Text {
                    text: "コンポーネントギャラリー"
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 24
                    font.bold: true
                }

                QsSectionLabel {
                    text: ThemeService.currentPalette + " / " + ThemeService.currentMode
                }
            }

            Item {
                Layout.fillWidth: true
            }

            QsButton {
                text: "閉じる"
                onClicked: root.visible = false
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 14

            Flickable {
                id: navigation

                Layout.fillWidth: false
                Layout.fillHeight: true
                Layout.preferredWidth: 132
                Layout.preferredHeight: 1
                contentWidth: width
                contentHeight: categories.height
                flickableDirection: Flickable.VerticalFlick
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                Controls.ScrollBar.vertical: Controls.ScrollBar {}

                ColumnLayout {
                    id: categories

                    width: navigation.width
                    spacing: 3

                    Repeater {
                        model: ["すべての部品", "ボタン", "入力", "表示", "ワークスペース", "メディア", "通知", "トークン"]
                        delegate: QsButton {
                            required property int index
                            required property string modelData

                            Layout.fillWidth: true
                            implicitHeight: 28
                            text: modelData
                            checkable: true
                            highlighted: root.category === index
                            onClicked: {
                                root.category = index;
                                gallery.contentY = 0;
                            }
                            onActiveFocusChanged: {
                                if (activeFocus)
                                    navigation.contentY = Math.max(y + height - navigation.height, Math.min(y, navigation.contentY));
                            }
                        }
                    }
                }
            }

            Flickable {
                id: gallery

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                Layout.preferredHeight: 1
                contentWidth: width
                contentHeight: stories.height
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                Controls.ScrollBar.vertical: Controls.ScrollBar {}

                ColumnLayout {
                    id: stories

                    width: Math.max(0, gallery.width - 12)
                    spacing: 12

                    ButtonStories {
                        visible: root.category === 0 || root.category === 1
                    }

                    InputStories {
                        visible: root.category === 0 || root.category === 2
                    }

                    DisplayStories {
                        visible: root.category === 0 || root.category === 3
                    }

                    WorkspaceStories {
                        visible: root.category === 0 || root.category === 4
                    }

                    MediaStories {
                        visible: root.category === 0 || root.category === 5
                        previewActive: root.visible
                    }

                    NotificationStories {
                        visible: root.category === 0 || root.category === 6
                        previewActive: root.visible
                    }

                    DesignTokens {
                        visible: root.category === root.tokensCategory
                    }
                }
            }
        }
    }
}
