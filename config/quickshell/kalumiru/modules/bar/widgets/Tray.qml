pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.SystemTray
import qs.ui.theme

Flickable {
    id: root

    required property int maximumWidth
    readonly property int itemCount: trayItems.count

    implicitWidth: Math.min(contentWidth, maximumWidth)
    implicitHeight: icons.implicitHeight
    contentWidth: icons.implicitWidth
    contentHeight: height
    clip: true
    flickableDirection: Flickable.HorizontalFlick
    boundsBehavior: Flickable.StopAtBounds
    interactive: contentWidth > width

    TrayMenu {
        id: contextMenu
    }

    Row {
        id: icons

        spacing: 2

        Repeater {
            id: trayItems

            model: SystemTray.items

            delegate: Rectangle {
                id: tile

                required property SystemTrayItem modelData
                width: 34
                height: 36
                radius: root.itemCount === 1 ? width / 2 : 8
                color: area.containsMouse || (contextMenu.visible && contextMenu.trayItem === modelData) ? Theme.hover : "transparent"

                Image {
                    anchors.centerIn: parent
                    width: 22
                    height: 22
                    source: tile.modelData.icon
                    sourceSize.width: width
                    sourceSize.height: height
                    fillMode: Image.PreserveAspectFit
                }

                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton && !tile.modelData.onlyMenu)
                            tile.modelData.activate();
                        else if (tile.modelData.hasMenu)
                            contextMenu.openFor(tile, tile.modelData);
                    }
                }
            }
        }
    }
}
