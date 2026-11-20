import QtQuick
import qs.ui.widgets
import qs.ui.theme
import qs.services

Rectangle {
    id: root
    implicitWidth: display.implicitWidth + 16
    implicitHeight: 36
    width: implicitWidth
    height: implicitHeight
    radius: 8
    color: "transparent"
    scale: area.pressed ? 0.94 : 1
    Behavior on scale {
        QsNumberAnimation {
            duration: Theme.motionFast
        }
    }

    required property var notificationService
    required property string outputName

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

    HoverHandler {
        id: statusHover
    }

    QsHoverBackground {
        hovered: statusHover.hovered
    }

    QsIconLabel {
        id: display
        hoverBackground: false
        hovered: statusHover.hovered
        anchors.centerIn: parent
        icon: notificationService.dnd ? Icons.bellSlash : Icons.bell
        text: notificationService.history.count > 0 ? notificationService.history.count.toString() : ""
    }

    MouseArea {
        id: area
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            ControlCenterService.visible = false;
            notificationService.toggleFor(root.outputName);
        }
    }
}
