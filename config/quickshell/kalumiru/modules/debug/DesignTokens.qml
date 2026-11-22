pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.ui.theme
import qs.ui.widgets

ColumnLayout {
    id: root

    property int section: 0
    property bool motionAtEnd: false

    Layout.fillWidth: true
    spacing: 12

    component TokenValue: Text {
        color: Theme.textPrimary
        font.family: "monospace"
        font.pixelSize: Theme.fontSizeSmall
    }

    Text {
        text: "デザイントークン"
        color: Theme.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeTitle
        font.bold: true
    }

    Flow {
        Layout.fillWidth: true
        spacing: 8

        Repeater {
            model: ["カラー", "文字", "寸法・モーション"]
            delegate: QsButton {
                required property int index
                required property string modelData

                text: modelData
                checkable: true
                highlighted: root.section === index
                onClicked: root.section = index
            }
        }
    }

    ColorTokens {
        visible: root.section === 0
    }

    QsPanelCard {
        visible: root.section === 1
        padding: 12
        spacing: 10

        QsSectionLabel {
            text: "fontFamily · " + Theme.fontFamily
        }

        StoryTextField {
            id: fontSample

            label: "プレビュー文字列"
            text: "日本語 Aa 0123"
        }

        Repeater {
            model: [
                ["fontSizeTitle", Theme.fontSizeTitle, "見出し"],
                ["fontSizeBody", Theme.fontSizeBody, "本文"],
                ["fontSizeSmall", Theme.fontSizeSmall, "補足・ラベル"]
            ]
            delegate: ColumnLayout {
                id: typeSample

                required property var modelData

                Layout.fillWidth: true
                spacing: 4

                TokenValue {
                    text: typeSample.modelData[0] + "  " + typeSample.modelData[1] + " px · " + typeSample.modelData[2]
                }

                Text {
                    Layout.fillWidth: true
                    text: fontSample.text
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: typeSample.modelData[1]
                    wrapMode: Text.Wrap
                }
            }
        }
    }

    QsPanelCard {
        visible: root.section === 2
        padding: 12
        spacing: 12

        QsSectionLabel {
            text: "角丸"
        }

        Flow {
            Layout.fillWidth: true
            spacing: 12

            Repeater {
                model: [
                    ["radiusSmall", Theme.radiusSmall],
                    ["radius", Theme.radius],
                    ["barRadius", Theme.barRadius],
                    ["radiusLarge", Theme.radiusLarge]
                ]
                delegate: ColumnLayout {
                    id: corner

                    required property var modelData
                    spacing: 5

                    Rectangle {
                        Layout.preferredWidth: 58
                        Layout.preferredHeight: 42
                        color: Theme.bgTertiary
                        border.color: Theme.border
                        radius: corner.modelData[1]
                    }

                    TokenValue {
                        text: corner.modelData[0]
                    }

                    QsSectionLabel {
                        text: corner.modelData[1] + " px"
                    }
                }
            }
        }

        QsSectionLabel {
            text: "余白・間隔"
        }

        Flow {
            Layout.fillWidth: true
            spacing: 12

            Repeater {
                model: [
                    ["padding", Theme.padding],
                    ["spacingSmall", Theme.spacingSmall],
                    ["spacing", Theme.spacing],
                    ["spacingLarge", Theme.spacingLarge]
                ]
                delegate: ColumnLayout {
                    id: gap

                    required property var modelData
                    spacing: 5

                    Row {
                        Layout.preferredHeight: 20
                        spacing: gap.modelData[1]

                        Rectangle {
                            width: 18
                            height: parent.height
                            color: Theme.accent
                        }

                        Rectangle {
                            width: 18
                            height: parent.height
                            color: Theme.accent
                        }
                    }

                    TokenValue {
                        text: gap.modelData[0]
                    }

                    QsSectionLabel {
                        text: gap.modelData[1] + " px"
                    }
                }
            }
        }

        QsSectionLabel {
            text: "バー・パネル・影"
        }

        Repeater {
            model: [
                ["barHeight", Theme.barHeight, "バーの高さ"],
                ["barOuterMargin", Theme.barOuterMargin, "バー外側の余白"],
                ["belowBar", Theme.belowBar, "バー下の表示位置"],
                ["popupInset", Theme.popupInset, "ポップアップの端からの距離"],
                ["controlWidth", Theme.controlWidth, "コントロールセンターの幅"],
                ["expandedWidth", Theme.expandedWidth, "バーの表示を広げるしきい値"],
                ["windowShadowBlur", Theme.windowShadowBlur, "影のぼかし"],
                ["windowShadowOffset", Theme.windowShadowOffset, "影の縦方向のずれ"],
                ["windowShadowPadding", Theme.windowShadowPadding, "影の描画に必要な余白"],
                ["toastSlide", Theme.toastSlide, "通知がスライドする距離"]
            ]
            delegate: RowLayout {
                id: dimension

                required property var modelData

                Layout.fillWidth: true
                spacing: 8

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    TokenValue {
                        text: dimension.modelData[0]
                    }

                    QsSectionLabel {
                        Layout.fillWidth: true
                        text: dimension.modelData[2]
                        wrapMode: Text.Wrap
                    }
                }

                TokenValue {
                    text: dimension.modelData[1] + " px"
                }
            }
        }
    }

    QsPanelCard {
        visible: root.section === 2
        padding: 12
        spacing: 10

        RowLayout {
            Layout.fillWidth: true

            QsSectionLabel {
                Layout.fillWidth: true
                text: "モーション"
            }

            QsButton {
                text: "再生"
                onClicked: root.motionAtEnd = !root.motionAtEnd
            }
        }

        Repeater {
            model: [
                ["motionFast", Theme.motionFast, "操作への反応"],
                ["motionNormal", Theme.motionNormal, "通常の遷移"],
                ["motionEnter", Theme.motionEnter, "表示"],
                ["motionExit", Theme.motionExit, "非表示"]
            ]
            delegate: ColumnLayout {
                id: motion

                required property var modelData

                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true

                    TokenValue {
                        Layout.fillWidth: true
                        text: motion.modelData[0] + "  " + motion.modelData[1] + " ms"
                    }

                    QsSectionLabel {
                        text: motion.modelData[2]
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 18
                    radius: 9
                    color: Theme.bgTertiary

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 12
                        height: 12
                        radius: 6
                        color: Theme.mustard800
                        x: root.motionAtEnd ? parent.width - width - 3 : 3

                        Behavior on x {
                            NumberAnimation {
                                duration: motion.modelData[1]
                            }
                        }
                    }
                }
            }
        }
    }
}
