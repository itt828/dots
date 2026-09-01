import QtQuick
import "../../Widgets/Bar" as BarParts

Item {
    id: root
    required property var moduleContext

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    BarParts.Clock {
        id: content
        anchors.centerIn: parent
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.moduleContext.services.dashboard.toggle()
    }
}
