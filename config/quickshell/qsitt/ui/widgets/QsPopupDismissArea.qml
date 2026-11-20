pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.services
import qs.ui.theme

MouseArea {
    id: root

    required property ShellScreen output
    property bool coverBar: false
    readonly property bool hasBar: SettingsService.targetScreens.length === 0 || SettingsService.targetScreens.includes(output.name)
    readonly property Region inputRegion: Region {
        item: root.enabled ? root : null

        Region {
            intersection: Intersection.Subtract
            item: root.enabled && root.hasBar && !root.coverBar ? barBounds : null
            radius: Theme.barRadius
            topLeftRadius: 0
            topRightRadius: 0
        }
    }

    anchors.fill: parent
    acceptedButtons: Qt.AllButtons

    Item {
        id: barBounds

        width: Math.max(0, root.width - 2 * Theme.barOuterMargin)
        height: Theme.barHeight
        x: Theme.barOuterMargin
    }
}
