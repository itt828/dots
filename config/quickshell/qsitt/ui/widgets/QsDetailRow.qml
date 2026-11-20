import QtQuick
import QtQuick.Layouts
import qs.ui.theme

RowLayout {
    id: root

    property string title: ""
    property string subtitle: ""
    property string icon: ""
    default property alias actions: trailing.data

    Layout.fillWidth: true
    spacing: 9

    Rectangle {
        Layout.preferredWidth: 34
        Layout.preferredHeight: 34
        radius: 9
        color: Theme.bgTertiary
        visible: root.icon !== ""

        QsIcon {
            anchors.centerIn: parent
            icon: root.icon
            size: 18
            color: Theme.mustard800
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        spacing: 2

        QsMarqueeText {
            Layout.fillWidth: true
            text: root.title
            textFormat: Text.PlainText
            color: Theme.ink
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeBody
            font.weight: Font.DemiBold
        }
        QsMarqueeText {
            visible: root.subtitle !== ""
            Layout.fillWidth: true
            text: root.subtitle
            textFormat: Text.PlainText
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    RowLayout {
        id: trailing
        spacing: 6
        visible: children.length > 0
    }
}
