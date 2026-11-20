pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.ui.theme
import qs.services
import qs.ui.widgets

ColumnLayout {
    spacing: Theme.spacing

    Text {
        text: "表示モード"
        color: Theme.textPrimary
        font.family: Theme.fontFamily
        font.bold: true
        font.pixelSize: Theme.fontSizeBody
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingSmall

        Repeater {
            model: ThemeService.availableModes

            delegate: QsButton {
                required property string modelData

                Layout.fillWidth: true
                text: ({
                        light: "ライト",
                        dark: "ダーク",
                        auto: "自動"
                    })[modelData]
                toolTip: modelData === "auto" ? "18:00〜6:00 はダーク" : ""
                horizontalPadding: 6
                labelSize: 12
                highlighted: ThemeService.configuredMode === modelData
                checkable: true
                onClicked: ThemeService.setMode(modelData)
            }
        }
    }

    Text {
        Layout.topMargin: Theme.spacing
        text: "テーマ"
        color: Theme.textPrimary
        font.family: Theme.fontFamily
        font.bold: true
        font.pixelSize: Theme.fontSizeBody
    }

    Flow {
        Layout.fillWidth: true
        spacing: Theme.spacingSmall

        Repeater {
            model: ThemeService.availablePalettes

            delegate: QsButton {
                required property var modelData

                text: modelData.label
                highlighted: ThemeService.currentPalette === modelData.name
                checkable: true
                onClicked: ThemeService.setPalette(modelData.name)
            }
        }
    }
}
