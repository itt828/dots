pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.Theme

Rectangle {
    id: root

    property date currentDate: new Date()
    readonly property int year: currentDate.getFullYear()
    readonly property int month: currentDate.getMonth()

    function getDaysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate();
    }

    function getFirstDayOffset(year, month) {
        return new Date(year, month, 1).getDay();
    }

    Layout.fillWidth: true
    implicitHeight: 350
    color: Theme.surface
    radius: 14
    border.color: Theme.outline
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingLarge
        spacing: 14

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 1

                Text {
            font.family: Theme.fontFamily
                    text: Qt.formatDate(root.currentDate, "dddd")
                    color: Theme.textSecondary
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                }

                Text {
            font.family: Theme.fontFamily
                    text: Qt.formatDate(root.currentDate, "MMMM d")
                    color: Theme.text
                    font.pixelSize: 26
                    font.weight: Font.DemiBold
                }
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                implicitWidth: monthLabel.implicitWidth + 24
                implicitHeight: 32
                radius: 16
                color: Theme.primaryContainer

                Text {
            font.family: Theme.fontFamily
                    id: monthLabel
                    anchors.centerIn: parent
                    text: Qt.formatDate(root.currentDate, "MMMM yyyy")
                    color: Theme.primary
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.DemiBold
                }
            }
        }

        GridLayout {
            id: weekGrid

            Layout.fillWidth: true
            columns: 7
            columnSpacing: 6
            uniformCellWidths: true

            Repeater {
                model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

                delegate: Text {
            font.family: Theme.fontFamily
                    required property string modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: 22
                    text: modelData
                    color: Theme.textSecondary
                    font.pixelSize: 10
                    font.weight: Font.Medium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        GridLayout {
            id: calendarGrid

            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 7
            columnSpacing: 6
            rowSpacing: 5
            uniformCellWidths: true

            Repeater {
                model: root.getFirstDayOffset(root.year, root.month)

                delegate: Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                }
            }

            Repeater {
                model: root.getDaysInMonth(root.year, root.month)

                delegate: Rectangle {
                    required property int index

                    readonly property bool isToday: index + 1 === root.currentDate.getDate()

                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    radius: 10
                    color: isToday ? Theme.primary : dayArea.containsMouse ? Theme.surfaceContainerHigh : "transparent"

                    Text {
            font.family: Theme.fontFamily
                        anchors.centerIn: parent
                        text: parent.index + 1
                        color: parent.isToday ? Theme.primaryText : Theme.text
                        font.pixelSize: Theme.fontSizeBody
                        font.weight: parent.isToday ? Font.DemiBold : Font.Normal
                    }

                    MouseArea {
                        id: dayArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
            }
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.currentDate = new Date()
    }
}
