import QtQuick
import QtQuick.Layouts

Item {
    id: root
    
    // API compatible with CircularValue
    property real value: 0.0 // 0.0 to 1.0
    property string iconName: ""
    property string labelText: ""
    property bool showLabel: false
    
    property color progressColor: "black"
    property color trackColor: "#aaaaaa"
    
    // Internal style
    property real iconSize: 20

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

            AIcon {
                visible: root.iconName !== ""
                icon: root.iconName
                size: root.iconSize
                Layout.alignment: Qt.AlignVCenter
                color: root.progressColor // Optional: Match color to progress? Or stick to default? 
                // Original code didn't set color for Image, but icons are usually colored.
                // Assuming text color might be needed. Let's start with inheriting or black.
                // Looking at BarValue usage, it has progressColor and trackColor.
            }

            AText {
                visible: root.showLabel
                text: root.labelText
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // Progress Bar
        Rectangle {
            Layout.fillWidth: true
            Layout.minimumWidth: 30 // Minimum width ensures bar is visible even if text/icon is small
            Layout.preferredHeight: 2
            color: root.trackColor
            radius: 1
            
            Rectangle {
                width: parent.width * Math.min(Math.max(root.value, 0.0), 1.0)
                height: parent.height
                color: root.progressColor
                radius: 1
            }
        }
    }
}
