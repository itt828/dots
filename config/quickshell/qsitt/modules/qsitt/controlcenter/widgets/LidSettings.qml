import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common.theme

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
        implicitHeight: 54
        radius: Theme.radius
        color: Theme.surface

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: "クラムシェルモード"
                    color: Theme.text
                    font.family: Theme.fontFamily
                }

                Text {
                    text: "有効な外部画面をすべて点灯して作業を続ける"
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            Text {
                text: SettingsService.lidClamshellMode ? "オン" : "オフ"
                color: SettingsService.lidClamshellMode ? Theme.accent : Theme.textSecondary
                font.family: Theme.fontFamily
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: SettingsService.set("lidClamshellMode", !SettingsService.lidClamshellMode)
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
