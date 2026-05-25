import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts

Item {
    id: root

    // Properties
    property real value: 0.0 // 0.0 to 1.0
    property string iconName: ""
    property string labelText: ""
    property bool showLabel: false

    // Style
    property color color: "#333333"
    property color progressColor: "#ffffff"
    property color trackColor: "#555555"
    property real strokeWidth: 3

    width: showLabel ? row.width : size
    height: size

    property real size: 24
    property real iconSize: size * 0.55

    RowLayout {
        id: row
        spacing: 6
        anchors.verticalCenter: parent.verticalCenter

        // Circular Progress Part
        Item {
            Layout.preferredWidth: root.size
            Layout.preferredHeight: root.size

            Shape {
                id: shape
                anchors.fill: parent
                layer.enabled: true
                layer.samples: 4

                // Track (Background Circle)
                ShapePath {
                    strokeColor: root.trackColor
                    strokeWidth: root.strokeWidth
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap

                    PathAngleArc {
                        centerX: root.size / 2
                        centerY: root.size / 2
                        radiusX: (root.size / 2) - (root.strokeWidth / 2)
                        radiusY: (root.size / 2) - (root.strokeWidth / 2)
                        startAngle: 0
                        sweepAngle: 360
                    }
                }

                // Progress (Foreground Arc)
                ShapePath {
                    strokeColor: root.progressColor
                    strokeWidth: root.strokeWidth
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap

                    PathAngleArc {
                        centerX: root.size / 2
                        centerY: root.size / 2
                        radiusX: (root.size / 2) - (root.strokeWidth / 2)
                        radiusY: (root.size / 2) - (root.strokeWidth / 2)
                        startAngle: -90
                        sweepAngle: 360 * root.value
                    }
                }
            }

            // Icon in Center
            AIcon {
                anchors.centerIn: parent
                icon: root.iconName
                size: root.iconSize
                color: root.progressColor
            }
        }

        // Optional Text using AText
        AText {
            visible: root.showLabel
            text: root.labelText
            Layout.alignment: Qt.AlignVCenter
        }
    }
}