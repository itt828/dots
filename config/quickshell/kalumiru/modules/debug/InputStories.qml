pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.ui.widgets

QsPanelCard {
    id: root

    property real level: 0.55

    padding: 14
    spacing: 12

    component SwitchSample: RowLayout {
        id: sample

        required property string label
        property alias checked: control.checked

        QsSwitch {
            id: control
            Accessible.name: sample.label
            onToggled: value => control.checked = value
        }

        QsSectionLabel {
            text: sample.label
        }
    }

    QsSectionLabel {
        text: "QsSwitch"
    }

    Flow {
        Layout.fillWidth: true
        spacing: 14

        SwitchSample {
            label: "オンから"
            checked: true
        }

        SwitchSample {
            label: "オフから"
        }

        SwitchSample {
            label: "無効"
            checked: true
            enabled: false
        }
    }

    QsSectionLabel {
        text: "QsSlider"
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        QsSlider {
            Layout.fillWidth: true
            Accessible.name: "サンプルスライダー"
            value: root.level
            onMoved: value => root.level = value
        }

        QsSectionLabel {
            Layout.minimumWidth: 42
            horizontalAlignment: Text.AlignRight
            text: Math.round(root.level * 100) + "%"
        }
    }

    QsSlider {
        Layout.fillWidth: true
        Accessible.name: "無効なスライダー"
        value: 0.3
        enabled: false
    }

    QsSectionLabel {
        text: "QsChoice"
    }

    ListModel {
        id: choices

        ListElement {
            label: "内蔵スピーカー"
        }
        ListElement {
            label: "ヘッドホン"
        }
        ListElement {
            label: "HDMI 出力"
        }
    }

    StoryTextField {
        label: "先頭の選択肢"
        text: choices.get(0).label
        onTextEdited: value => choices.setProperty(0, "label", value)
    }

    Flow {
        Layout.fillWidth: true
        spacing: 8

        QsChoice {
            model: choices
            textRole: "label"
        }

        QsChoice {
            model: ["利用不可"]
            enabled: false
        }
    }
}
