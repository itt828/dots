import QtQuick
import qs.ui.widgets
import qs.ui.theme
import qs.services

Rectangle {
    id: root
    implicitWidth: display.implicitWidth + 20
    implicitHeight: 28
    width: implicitWidth
    height: implicitHeight
    radius: height / 2
    color: Theme.surfaceContainerHigh
    Behavior on color {
        QsColorAnimation {}
    }
    scale: area.pressed ? 0.94 : 1
    Behavior on scale {
        QsNumberAnimation {
            duration: Theme.motionFast
        }
    }

    required property var notificationService

    QsHighlightEffect {
        id: highlight
        cornerRadius: root.radius
    }

    Connections {
        target: notificationService
        function onDndChanged() {
            highlight.flash();
        }
    }

    property int lastCount: notificationService.history.count
    onLastCountChanged: {
        highlight.flash();
    }

    QsIconLabel {
        id: display
        anchors.centerIn: parent
        icon: notificationService.dnd ? Icons.bellSlash : (notificationService.history.count > 0 ? Icons.bellRinging : Icons.bell)
        text: notificationService.history.count.toString()
    }

    MouseArea {
        id: area
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            ControlCenterService.visible = false;
            notificationService.panelVisible = !notificationService.panelVisible;
        }
    }
}
