pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../../Assets"
import "../../Surfaces"

Rectangle {
    id: root
    required property var moduleContext

    anchors {
        top: parent.top
        left: parent.left
        right: parent.right
    }

    implicitHeight: Theme.barHeight
    color: Theme.surface

    RowLayout {
        anchors {
            fill: parent
            leftMargin: Theme.barHorizontalPadding
            rightMargin: Theme.barHorizontalPadding
        }
        spacing: Theme.barSectionSpacing

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            BarModuleRow {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.barModuleSpacing
                moduleNames: Config.barLayout.left
                moduleContext: root.moduleContext
            }
        }

        BarModuleRow {
            Layout.alignment: Qt.AlignCenter
            spacing: Theme.barModuleSpacing
            moduleNames: Config.barLayout.center
            moduleContext: root.moduleContext
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            BarModuleRow {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.barModuleSpacing
                moduleNames: Config.barLayout.right
                moduleContext: root.moduleContext
            }
        }
    }
}
