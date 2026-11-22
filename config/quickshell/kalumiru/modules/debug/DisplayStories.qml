pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.ui.theme
import qs.ui.widgets

ColumnLayout {
    Layout.fillWidth: true
    spacing: 12

    QsPanelCard {
        padding: 14
        spacing: 12

        QsSectionLabel {
            text: "QsSummaryCard"
        }

        StoryTextField {
            id: titleText

            label: "タイトル・アイコンラベル"
            text: "内蔵スピーカー"
        }

        StoryTextField {
            id: subtitleText

            label: "補足（カード・詳細行）"
            text: "既定の出力デバイス"
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            QsSummaryCard {
                title: titleText.text
                subtitle: subtitleText.text
                icon: Icons.volumeHigh
                compact: true
                active: true
                onClicked: active = !active
            }

            QsSummaryCard {
                title: "Bluetooth"
                subtitle: active ? "オン" : "オフ"
                icon: Icons.bluetooth
                compact: true
                onClicked: active = !active
            }
        }

        QsSectionLabel {
            text: "QsDetailRow / QsIconLabel"
        }

        QsDetailRow {
            title: titleText.text
            subtitle: subtitleText.text
            icon: Icons.volumeHigh
        }

        QsIconLabel {
            text: titleText.text
            icon: Icons.volumeHigh
        }
    }

    QsPanelCard {
        padding: 14
        spacing: 12

        QsSectionLabel {
            text: "QsProgressBar"
        }

        QsProgressBar {
            Layout.fillWidth: true
            value: 0.65
        }

        QsSectionLabel {
            text: "QsBarValue / QsCircularValue"
        }

        Flow {
            Layout.fillWidth: true
            spacing: 16

            QsBarValue {
                iconName: Icons.volumeMedium
                value: 0.4
                progressColor: Theme.textPrimary
            }

            QsCircularValue {
                iconName: Icons.batteryHigh
                value: 0.8
                progressColor: Theme.mustard800
                trackColor: Theme.borderPrimary
            }
        }

        QsSectionLabel {
            text: "QsMarqueeText"
        }

        StoryTextField {
            id: sampleText
            label: "表示する文字"
            text: "マウスを重ねると、長いテキストがスクロールします"
        }

        QsMarqueeText {
            Layout.fillWidth: true
            Layout.maximumWidth: 200
            text: sampleText.text
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeBody
        }
    }
}
