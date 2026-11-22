pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.services
import qs.ui.theme
import qs.ui.widgets

ColumnLayout {
    id: root

    property string previewMode: ""
    readonly property string mode: previewMode || ThemeService.currentMode
    readonly property var colors: ThemeService.paletteData[mode]
    readonly property color lightBackground: ThemeService.paletteData.light["bg-primary"]
    readonly property color darkBackground: ThemeService.paletteData.dark["bg-primary"]

    Layout.fillWidth: true
    spacing: 12

    component ColorGroup: QsPanelCard {
        id: group

        required property string title
        required property var tokens
        property string note: ""

        padding: 12
        spacing: 10

        Text {
            text: group.title
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeBody
            font.bold: true
        }

        QsSectionLabel {
            visible: group.note !== ""
            text: group.note
        }

        GridLayout {
            Layout.fillWidth: true
            columns: Math.max(1, Math.min(3, Math.floor((width + 8) / 135)))
            columnSpacing: 8
            rowSpacing: 12

            Repeater {
                model: group.tokens
                delegate: ColumnLayout {
                    id: tile

                    required property var modelData
                    readonly property color baseColor: root.colors[modelData[1]]
                    readonly property color swatch: modelData.length > 2 ? Theme.withAlpha(baseColor, modelData[2]) : baseColor

                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.alignment: Qt.AlignTop
                    spacing: 3

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        color: tile.swatch
                        radius: Theme.radiusSmall
                        gradient: tile.swatch.a < 1 ? splitBackground : null

                        Gradient {
                            id: splitBackground

                            orientation: Gradient.Horizontal
                            GradientStop {
                                position: 0
                                color: root.lightBackground
                            }
                            GradientStop {
                                position: 0.5
                                color: root.lightBackground
                            }
                            GradientStop {
                                position: 0.5
                                color: root.darkBackground
                            }
                            GradientStop {
                                position: 1
                                color: root.darkBackground
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: tile.swatch.a < 1 ? tile.swatch : "transparent"
                            radius: parent.radius
                            border.width: 1
                            border.color: Theme.borderPrimary
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: tile.modelData[0]
                        color: Theme.textPrimary
                        font.family: "monospace"
                        font.pixelSize: Theme.fontSizeSmall
                        elide: Text.ElideRight
                    }

                    TextEdit {
                        Layout.fillWidth: true
                        text: tile.swatch.toString().toUpperCase()
                        color: Theme.muted
                        font.family: "monospace"
                        font.pixelSize: Theme.fontSizeSmall
                        readOnly: true
                        selectByMouse: true
                        selectionColor: Theme.accent
                        selectedTextColor: Theme.ink
                        Accessible.name: tile.modelData[0] + " の色コード"
                    }                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        QsChoice {
            model: ["現在のモード", "ライト", "ダーク"]
            Accessible.name: "カラープレビューのモード"
            onActivated: index => root.previewMode = ["", "light", "dark"][index]
        }

        QsSectionLabel {
            Layout.fillWidth: true
            text: ThemeService.currentPalette + " / " + root.mode
            elide: Text.ElideRight
        }
    }

    ColorGroup {
        title: "背景・文字・境界"
        tokens: [
            ["bgPrimary", "bg-primary"],
            ["bgSecondary", "bg-secondary"],
            ["bgTertiary", "bg-tertiary"],
            ["surface", "surface"],
            ["textPrimary", "text-primary"],
            ["textSecondary", "text-secondary"],
            ["ink", "ink"],
            ["muted", "muted"],
            ["borderPrimary", "border-primary"],
            ["border", "border"]
        ]
    }

    ColorGroup {
        title: "操作と状態"
        tokens: [
            ["accent", "accent"],
            ["accentHover", "accent-hover"],
            ["accentPressed", "accent-pressed"],
            ["subtle", "subtle"],
            ["hover", "hover"],
            ["pressed", "pressed"],
            ["focus", "focus"],
            ["disabled", "disabled"],
            ["disabledInk", "disabled-ink"]
        ]
    }

    ColorGroup {
        title: "フィードバックと削除操作"
        tokens: [
            ["success", "success"],
            ["warn", "warn"],
            ["statusError", "status/error"],
            ["info", "info"],
            ["error", "error"],
            ["errorHover", "error-hover"],
            ["errorPressed", "error-pressed"],
            ["errorSurface", "error-surface"]
        ]
    }

    ColorGroup {
        title: "半透明の面と影"
        note: "透過色は #AARRGGBB"
        tokens: [
            ["glassPanel", "surface", Theme.glassPanel.a],
            ["glassPopup", "bg-tertiary", Theme.glassPopup.a],
            ["glassOutline", "border-primary", Theme.glassOutline.a],
            ["glassScrim", "ink", Theme.glassScrim.a],
            ["shadow", "shadow"]
        ]
    }

    ColorGroup {
        title: "基礎色"
        tokens: [
            ["mustard50", "mustard/50"],
            ["mustard200", "mustard/200"],
            ["mustard500", "mustard/500"],
            ["mustard800", "mustard/800"],
            ["canvasWarm", "canvas/warm"]
        ]
    }
}
