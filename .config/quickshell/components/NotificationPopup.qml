import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Notifications
import "UI"

Rectangle {
    id: root
    
    property var notification // The Notification object
    property bool isPopup: true // True if showing as popup, False if in center

    width: 300
    height: Math.min(layout.implicitHeight + 20, 150) // Max height cap
    color: "#eef2f5"
    radius: 8
    clip: true

    signal closed()

    Timer {
        interval: 5000
        running: root.isPopup
        repeat: false
        onTriggered: root.closed()
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Icon
        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 8
            color: "transparent"

            Image {
                id: iconImage
                anchors.fill: parent
                source: (root.notification && root.notification.icon) ? root.notification.icon : "image://icon/dialog-information"
                fillMode: Image.PreserveAspectFit
                visible: source != ""
                onStatusChanged: if (status == Image.Error) visible = false
            }
            
            AIcon {
                anchors.centerIn: parent
                icon: "dialog-information" // Fallback
                size: 32
                visible: iconImage.status == Image.Error || iconImage.source == ""
            }
        }

        // Text Content
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                AText {
                    text: (root.notification && root.notification.appName) ? root.notification.appName : "System"
                    font.pixelSize: 10
                    opacity: 0.7
                    Layout.fillWidth: true
                }
                
                // Close button for popups
                AIcon {
                    visible: root.isPopup
                    icon: "window-close"
                    size: 16
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.notification && root.notification.close) root.notification.close()
                            root.closed()
                        }
                    }
                }
            }

            AText {
                text: (root.notification && root.notification.summary) ? root.notification.summary : ""
                font.bold: true
                font.pixelSize: 13
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            AText {
                text: (root.notification && root.notification.body) ? root.notification.body : ""
                font.pixelSize: 12
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideRight
                Layout.fillWidth: true
                opacity: 0.9
            }
        }
    }
    
    // Popup timeout visualization (optional)
    Rectangle {
        visible: root.isPopup
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        height: 2
        width: parent.width
        color: "#0078d4"
        
        // Animation could be added here
    }
}
