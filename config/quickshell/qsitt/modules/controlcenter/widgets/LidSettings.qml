import QtQuick
import QtQuick.Layouts
import qs.services
import qs.ui.theme
import qs.ui.widgets

ColumnLayout {
    spacing: Theme.spacingSmall

    Text {
        text: "蓋を閉じたとき"
        color: Theme.text
        font.family: Theme.fontFamily
        font.bold: true
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: lidRow.implicitHeight + 24
        radius: Theme.radius
        color: Theme.surface

        RowLayout {
            id: lidRow
            anchors.fill: parent
            anchors.margins: 12
            spacing: Theme.spacing

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: "クラムシェルモード"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    wrapMode: Text.Wrap
                }

                Text {
                    Layout.fillWidth: true
                    text: "有効な外部画面をすべて点灯して作業を続ける"
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.Wrap
                }
            }

            QsSwitch {
                checked: SettingsService.lidClamshellMode
                Accessible.role: Accessible.CheckBox
                Accessible.name: "クラムシェルモード"
                Accessible.checkable: true
                Accessible.checked: checked
                Accessible.onToggleAction: toggle()
                onToggled: checked => SettingsService.set("lidClamshellMode", checked)
            }
        }
    }

    Text {
        Layout.fillWidth: true
        text: "外部画面がないとき、またはオフのときはロックしてサスペンドします。"
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        wrapMode: Text.Wrap
    }
}
