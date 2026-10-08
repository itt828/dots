import QtQuick
import Quickshell.Services.SystemTray

Row {
    id: root
    spacing: 10

    required property var rootWindow

    Repeater {
        model: SystemTray.items

        delegate: Column {
            spacing: 20

            Image {
                width: 16
                height: 16
                source: modelData.icon
                fillMode: Image.PreserveAspectFit

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton) {
                            modelData.activate();
                        } else if (mouse.button === Qt.RightButton) {
                            var pos = mapToItem(null, mouse.x, mouse.y);
                            modelData.display(root.rootWindow, Math.floor(pos.x), Math.floor(pos.y));
                        }
                    }
                }
            }
        }
    }
}
