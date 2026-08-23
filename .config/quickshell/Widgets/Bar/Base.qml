import QtQuick
import QtQuick.Layouts
import "../../Components"

Rectangle {
    id: root

    default property alias content: layout.data
    property alias leftContent: leftLayout.data
    property alias centerContent: centerLayout.data
    property alias rightContent: rightLayout.data

    color: "#c4d0d6" // oklch(0.85 0.015 228)
    border.color: "#6f8792"
    border.width: 2

    anchors {
        top: parent.top
        left: parent.left
        right: parent.right
        leftMargin: 8
        rightMargin: 8
        topMargin: 8
    }

    implicitHeight: layout.implicitHeight + 12

    bottomLeftRadius: 8
    bottomRightRadius: 8
    topLeftRadius: 8
    topRightRadius: 8

    RowLayout {
        id: layout
        anchors {
            fill: parent
            leftMargin: 12
            rightMargin: 12
            topMargin: 0
            bottomMargin: 0
        }
        spacing: 12

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            RowLayout {
                id: leftLayout
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12
            }
        }

        RowLayout {
            id: centerLayout
            Layout.alignment: Qt.AlignCenter
            spacing: 12
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            RowLayout {
                id: rightLayout
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12
            }
        }
    }
}
