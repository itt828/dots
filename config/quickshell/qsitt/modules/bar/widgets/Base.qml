import QtQuick
import QtQuick.Layouts
import qs.ui.theme

Rectangle {
    id: root

    property alias leftContent: leftLayout.data
    property alias centerContent: centerLayout.data
    property alias centerTrailingContent: centerTrailing.data
    property alias rightContent: rightLayout.data

    readonly property real centerTrailingWidth: centerTrailing.implicitWidth
    readonly property real rightWidth: rightLayout.implicitWidth
    readonly property int padding: 8
    color: Theme.surface
    radius: Theme.barRadius
    topLeftRadius: 0
    topRightRadius: 0
    border.color: Theme.borderPrimary
    border.width: 1

    anchors {
        top: parent.top
        left: parent.left
        right: parent.right
        leftMargin: Theme.barOuterMargin
        rightMargin: Theme.barOuterMargin
    }

    implicitHeight: Theme.barHeight

    Behavior on color {
        ColorAnimation {
            duration: Theme.motionFast
        }
    }

    RowLayout {
        id: leftLayout
        anchors {
            left: parent.left
            leftMargin: root.padding
            right: centerLayout.implicitWidth > 0 ? centerLayout.left : centerTrailing.left
            rightMargin: 8
            verticalCenter: parent.verticalCenter
        }
        spacing: 8
    }

    RowLayout {
        id: centerLayout
        anchors.centerIn: parent
    }

    RowLayout {
        id: centerTrailing

        x: centerLayout.implicitWidth > 0 ? centerLayout.x + centerLayout.width + 8 : (root.width - width) / 2
        anchors.verticalCenter: parent.verticalCenter
    }

    RowLayout {
        id: rightLayout
        anchors {
            right: parent.right
            rightMargin: root.padding
            verticalCenter: parent.verticalCenter
        }
        spacing: 0
    }
}
