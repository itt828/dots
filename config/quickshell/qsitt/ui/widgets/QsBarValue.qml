import QtQuick
import qs.ui.theme
import QtQuick.Layouts

Item {
    id: root

    property real value: 0.0
    property string iconName: ""
    property string labelText: ""
    property bool showLabel: false

    property color progressColor: "black"
    property color trackColor: Theme.outline

    property real iconSize: 16

    width: column.width
    height: column.height
    implicitWidth: column.implicitWidth
    implicitHeight: column.implicitHeight

    ColumnLayout {
        id: column
        spacing: 4
        anchors.centerIn: parent

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 6

            QsIcon {
                visible: root.iconName !== ""
                icon: root.iconName
                size: root.iconSize
                Layout.alignment: Qt.AlignVCenter
                color: root.progressColor
            }

            Text {
                font.family: Theme.fontFamily
                visible: root.showLabel
                text: root.labelText
                Layout.alignment: Qt.AlignVCenter
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.minimumWidth: 30
            Layout.preferredHeight: 2
            color: root.trackColor
            radius: 1

            Rectangle {
                width: parent.width * Math.min(Math.max(root.value, 0.0), 1.0)
                Behavior on width {
                    QsNumberAnimation {}
                }
                height: parent.height
                color: root.progressColor
                radius: 1
            }
        }
    }
}
