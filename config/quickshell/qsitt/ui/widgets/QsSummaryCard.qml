import QtQuick
import QtQuick.Layouts
import qs.ui.theme
import qs.ui.widgets

Rectangle {
    id: root
    required property string title
    required property string subtitle
    required property string icon
    property bool active: false
    signal clicked
    Layout.fillWidth: true
    Layout.preferredWidth: 1
    implicitHeight: 116
    radius: 16
    color: area.containsMouse ? Theme.surfaceContainerHigh : active ? Theme.primaryContainer : Theme.surfaceContainer
    border.color: active ? Theme.withAlpha(Theme.primary, 0.3) : Theme.outlineVariant
    border.width: 1
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 5
        RowLayout {
            Layout.fillWidth: true
            QsIcon {
                icon: root.icon
                size: 23
                color: root.active ? Theme.primary : Theme.textSecondary
            }
            Item {
                Layout.fillWidth: true
            }
            Text {
                text: "›"
                color: Theme.textSecondary
                font.pixelSize: 20
            }
        }
        Text {
            text: root.title
            color: Theme.text
            font.family: Theme.fontFamily
            font.bold: true
        }
        Text {
            Layout.fillWidth: true
            text: root.subtitle
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: 11
            elide: Text.ElideRight
        }
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
