import QtQuick
import qs.ui.theme
import QtQuick.Shapes
import QtQuick.Layouts

Item {
    id: root

    property real value: 0.0
    property string iconName: ""
    property string labelText: ""
    property bool showLabel: false

    property color color: Theme.textPrimary
    property color progressColor: Theme.surface
    property color trackColor: Theme.textSecondary
    property real strokeWidth: 3

    width: showLabel ? row.width : size
    height: size

    property real size: 24
    property real iconSize: size * 0.55

    RowLayout {
        id: row
        spacing: 6
        anchors.verticalCenter: parent.verticalCenter

        Item {
            Layout.preferredWidth: root.size
            Layout.preferredHeight: root.size

            Shape {
                id: shape
                anchors.fill: parent
                layer.enabled: true
                layer.samples: 4

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
                        Behavior on sweepAngle {
                            QsNumberAnimation {}
                        }
                    }
                }
            }

            QsIcon {
                anchors.centerIn: parent
                icon: root.iconName
                size: root.iconSize
                color: root.progressColor
            }
        }

        Text {
            font.family: Theme.fontFamily
            visible: root.showLabel
            text: root.labelText
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
