import QtQuick
import Quickshell
import qs.ui.theme
import qs.ui.widgets

Item {
    id: root

    // Track ancestor positions so the mask also updates when an entire row moves.
    readonly property point positionInWindow: {
        let x = 0;
        let y = 0;
        for (let item = root; item; item = item.parent) {
            x += item.x;
            y += item.y;
        }
        return Qt.point(x, y);
    }

    readonly property Region inputRegion: Region {
        x: Math.floor(root.positionInWindow.x)
        y: Math.floor(root.positionInWindow.y)
        width: root.visible ? Math.ceil(root.width) : 0
        height: root.visible ? Math.ceil(root.height) : 0
        radius: background.radius
    }

    implicitHeight: Theme.barPillHeight

    QsWindowShadow {
        surface: background
        blur: 9
        offset: Qt.vector2d(0, 3)
    }

    Rectangle {
        id: background

        anchors.fill: parent
        color: Theme.surface
        radius: Math.min(Theme.barRadius, width / 2)
        border.color: Theme.borderPrimary
        border.width: 1

        Behavior on color {
            QsColorAnimation {}
        }
    }
}
