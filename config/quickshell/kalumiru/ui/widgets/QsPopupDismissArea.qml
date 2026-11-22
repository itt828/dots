pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

MouseArea {
    id: root

    property Region passthroughRegion: null
    readonly property Region inputRegion: Region {
        item: root.enabled ? root : null

        Region {
            intersection: Intersection.Subtract
            regions: root.enabled && root.passthroughRegion ? [root.passthroughRegion] : []
        }
    }

    anchors.fill: parent
    acceptedButtons: Qt.AllButtons
}
