import QtQuick
import QtQuick.Layouts
import qs.modules.common.theme
import qs.services

ColumnLayout {
    spacing: Theme.spacingSmall

    Text {
        text: "Theme"
        color: Theme.text
        font.family: Theme.fontFamily
        font.bold: true
        font.pointSize: 12
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 54
        radius: Theme.radius
        color: Theme.surface

        RowLayout {
            anchors.fill: parent
            anchors.margins: 6
            spacing: Theme.spacingSmall

            Repeater {
                model: ThemeService.availablePalettes

                delegate: Rectangle {
                    id: option

                    required property var modelData
                    readonly property bool selected: ThemeService.currentPalette === modelData.name

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Theme.radiusSmall
                    color: selected ? Theme.primaryContainer : (optionArea.containsMouse ? Theme.surfaceContainerHigh : "transparent")
                    border.color: selected ? Theme.primary : "transparent"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacingSmall

                        Text {
                            text: option.modelData.label
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeBody
                            font.weight: option.selected ? Font.DemiBold : Font.Normal
                        }
                    }

                    MouseArea {
                        id: optionArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ThemeService.setPalette(option.modelData.name)
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                Layout.topMargin: 6
                Layout.bottomMargin: 6
                color: Theme.outline
            }

            Repeater {
                model: ThemeService.availableModes

                delegate: Rectangle {
                    id: modeOption

                    required property string modelData
                    readonly property bool selected: ThemeService.currentMode === modelData

                    Layout.preferredWidth: 58
                    Layout.fillHeight: true
                    radius: Theme.radiusSmall
                    color: selected ? Theme.primary : (modeArea.containsMouse ? Theme.surfaceContainerHigh : "transparent")

                    Text {
                        anchors.centerIn: parent
                        text: modeOption.modelData === "light" ? "Light" : "Dark"
                        color: modeOption.selected ? Theme.primaryText : Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: modeOption.selected ? Font.DemiBold : Font.Normal
                    }

                    MouseArea {
                        id: modeArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ThemeService.setMode(modeOption.modelData)
                    }
                }
            }
        }
    }
}
