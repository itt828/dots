import QtQuick
import QtQuick.Layouts
import "../UI"

Rectangle {
    id: root
    color: "#dddddd"
    radius: 12
    Layout.fillWidth: true
    Layout.preferredHeight: childrenRect.height + 20

    property date currentDate: new Date()
    property int year: currentDate.getFullYear()
    property int month: currentDate.getMonth()

    function getDaysInMonth(y, m) {
        return new Date(y, m + 1, 0).getDate();
    }

    function getFirstDayOffset(y, m) {
        return new Date(y, m, 1).getDay(); // 0 is Sunday
    }

    ColumnLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        spacing: 10

        // Header
        AText {
            text: Qt.formatDateTime(root.currentDate, "MMMM yyyy")
            font.bold: true
            font.pixelSize: 16
            Layout.alignment: Qt.AlignHCenter
        }

        // Days of week
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 5
            Repeater {
                model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                AText {
                    text: modelData
                    Layout.preferredWidth: 30
                    horizontalAlignment: Text.AlignHCenter
                    opacity: 0.6
                    font.pixelSize: 10
                }
            }
        }

        // Calendar Grid
        GridLayout {
            columns: 7
            rowSpacing: 5
            columnSpacing: 5
            Layout.alignment: Qt.AlignHCenter

            // Empty slots for start offset
            Repeater {
                model: root.getFirstDayOffset(root.year, root.month)
                Item {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                }
            }

            // Days
            Repeater {
                model: root.getDaysInMonth(root.year, root.month)
                
                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    radius: 15
                    
                    property bool isToday: (index + 1) === root.currentDate.getDate()
                    color: isToday ? "black" : "transparent"

                    AText {
                        anchors.centerIn: parent
                        text: index + 1
                        color: parent.isToday ? "white" : "black"
                    }
                }
            }
        }
    }
}
