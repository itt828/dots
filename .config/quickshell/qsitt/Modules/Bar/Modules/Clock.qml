import QtQuick
import qs.Modules.Bar.Widgets as BarParts
import qs.Services

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
        onClicked: ControlCenterService.toggle()
    }
}
