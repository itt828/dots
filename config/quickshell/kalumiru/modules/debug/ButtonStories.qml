pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import qs.ui.theme
import qs.ui.widgets

QsPanelCard {
    id: root

    readonly property string defaultLabel: "サンプル"
    property bool selected: true
    property string lastClicked: "—"

    padding: 14
    spacing: 12

    component ButtonSample: ColumnLayout {
        id: sample

        required property string label
        property alias variant: control.variant
        property alias icon: control.icon
        property alias checkable: control.checkable
        property alias highlighted: control.highlighted
        signal activated

        spacing: 4

        QsButton {
            id: control

            Layout.alignment: Qt.AlignHCenter
            text: icon === "" ? buttonLabel.text : ""
            toolTip: icon !== "" ? sample.label : ""
            Accessible.name: text || sample.label
            onClicked: {
                root.lastClicked = sample.label;
                sample.activated();
            }
        }

        QsSectionLabel {
            Layout.alignment: sample.width > preview.width ? Qt.AlignLeft : Qt.AlignHCenter
            text: sample.label
        }
    }

    QsSectionLabel {
        text: "QsButton"
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        StoryTextField {
            id: buttonLabel

            label: "ボタンのラベル（一括）"
            text: root.defaultLabel
        }

        QsButton {
            Layout.alignment: Qt.AlignBottom
            text: "元に戻す"
            enabled: buttonLabel.text !== root.defaultLabel
            onClicked: buttonLabel.text = root.defaultLabel
        }
    }

    QsSectionLabel {
        visible: preview.interactive
        text: "横スクロールでラベルの続きを確認"
    }

    Flickable {
        id: preview

        Layout.fillWidth: true
        Layout.preferredHeight: variants.implicitHeight + (interactive ? 12 : 0)
        contentWidth: Math.max(width, variants.childrenRect.width)
        contentHeight: height
        interactive: contentWidth > width
        clip: interactive
        flickableDirection: Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds

        Controls.ScrollBar.horizontal: Controls.ScrollBar {
            policy: preview.interactive ? Controls.ScrollBar.AlwaysOn : Controls.ScrollBar.AlwaysOff
        }

        Flow {
            id: variants

            width: preview.width
            spacing: 8

            ButtonSample {
                label: "プライマリ"
                variant: QsButton.Primary
            }

            ButtonSample {
                label: "セカンダリ"
            }

            ButtonSample {
                label: "ゴースト"
                variant: QsButton.Ghost
            }

            ButtonSample {
                label: "破壊的"
                variant: QsButton.Destructive
            }

            ButtonSample {
                label: "無効"
                enabled: false
            }

            ButtonSample {
                label: "選択切り替え"
                checkable: true
                highlighted: root.selected
                onActivated: root.selected = !root.selected
            }

            ButtonSample {
                label: "アイコンのみ"
                icon: Icons.settings
            }
        }
    }

    QsSectionLabel {
        text: "最後に押したボタン  " + root.lastClicked
    }
}
