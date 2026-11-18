pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.ui.theme
import qs.ui.widgets
import qs.services
import qs.modules.controlcenter.widgets

Flickable {
    id: root

    clip: true
    contentWidth: width
    contentHeight: settingsColumn.implicitHeight
    boundsBehavior: Flickable.StopAtBounds

    ColumnLayout {
        id: settingsColumn

        width: root.width
        spacing: Theme.spacingLarge

        Text {
            Layout.fillWidth: true
            text: "変更はすぐに反映され、自動的に保存されます。"
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.Wrap
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: appearance.implicitHeight + 32
            radius: Theme.radius
            color: Theme.surfaceContainer

            ThemeSwitcher {
                id: appearance
                anchors.fill: parent
                anchors.margins: 16
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSmall

            Text {
                text: "Control Center"
                color: Theme.text
                font.family: Theme.fontFamily
                font.bold: true
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: mediaRow.implicitHeight + 24
                radius: Theme.radius
                color: Theme.surfaceContainer

                RowLayout {
                    id: mediaRow
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: Theme.spacing

                    Text {
                        Layout.fillWidth: true
                        text: "再生中のメディア情報を表示"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBody
                        wrapMode: Text.Wrap
                    }

                    QsSwitch {
                        checked: SettingsService.showMediaInfo
                        Accessible.role: Accessible.CheckBox
                        Accessible.name: "再生中のメディア情報を表示"
                        Accessible.checkable: true
                        Accessible.checked: checked
                        Accessible.onToggleAction: toggle()
                        onToggled: checked => SettingsService.set("showMediaInfo", checked)
                    }
                }
            }
        }

        LidSettings {
            Layout.fillWidth: true
        }
    }
}
