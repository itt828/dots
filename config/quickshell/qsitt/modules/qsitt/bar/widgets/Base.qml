import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets
import qs.modules.common.theme

Rectangle {
    id: root

    default property alias content: layout.data
    property alias leftContent: leftLayout.data
    property alias centerContent: centerLayout.data
    property alias rightContent: rightLayout.data

    color: Theme.surfaceContainerLow
    border.color: Theme.outlineVariant
    border.width: Theme.barBorderWidth

    anchors {
        top: parent.top
        left: parent.left
        right: parent.right
        leftMargin: Theme.barOuterMargin
        rightMargin: Theme.barOuterMargin
        topMargin: Theme.barOuterMargin
    }

    implicitHeight: layout.implicitHeight + Theme.barHorizontalPadding

    bottomLeftRadius: Theme.radius
    bottomRightRadius: Theme.radius
    topLeftRadius: Theme.radius
    topRightRadius: Theme.radius

    RowLayout {
        id: layout
        anchors {
            fill: parent
            leftMargin: Theme.barHorizontalPadding
            rightMargin: Theme.barHorizontalPadding
            topMargin: 0
            bottomMargin: 0
        }
        spacing: Theme.barSectionSpacing

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            RowLayout {
                id: leftLayout
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.barSectionSpacing
            }
        }

        RowLayout {
            id: centerLayout
            Layout.alignment: Qt.AlignCenter
            spacing: Theme.barSectionSpacing
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            RowLayout {
                id: rightLayout
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.barSectionSpacing
            }
        }
    }
}
