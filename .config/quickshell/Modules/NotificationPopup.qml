import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Notifications
import "../Widgets"
import "../Common"

Rectangle {
    id: root
    
    property var notification // The Notification object
    property bool isPopup: true // True if showing as popup, False if in center

    property string appName: (notification && notification.appName) ? notification.appName : "System"
    property string summary: (notification && notification.summary) ? notification.summary : ""
    property string body: (notification && notification.body) ? notification.body : ""
    property string appIconSource: ""
    property string iconSource: ""
    property string imageSource: ""

    width: 300
    height: Math.min(layout.implicitHeight + 20, 350) // Max height cap
    color: "#eef2f5"
    radius: 8
    clip: true

    signal closed()

    function resolveIcon(icon, fallback) {
        if (!icon) return fallback ? resolveIcon(fallback) : "";
        if (icon.indexOf("/") >= 0 || icon.indexOf("file://") >= 0 || icon.indexOf("image://") >= 0) return icon;
        return Quickshell.iconPath(icon, fallback || "");
    }

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

        // Icon (Left side - strictly for App Identity)
        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 8
            color: "transparent"

            Image {
                id: iconImage
                anchors.fill: parent
                // Prioritize App Icon, then App Name, then generic notification icon
                source: {
                    var src = resolveIcon(root.appIconSource);
                    if (!src) src = resolveIcon(root.appName.toLowerCase());
                    if (!src) src = resolveIcon(root.iconSource);
                    return src || Quickshell.iconPath("dialog-information");
                }
                fillMode: Image.PreserveAspectFit
                onStatusChanged: if (status == Image.Error) visible = false
            }
            
            AIcon {
                anchors.centerIn: parent
                icon: "dialog-information" // Fallback
                size: 32
                visible: iconImage.status == Image.Error || iconImage.source == "" || iconImage.status == Image.Null
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
                    text: root.appName
                    font.pixelSize: 10
                    opacity: 0.7
                    Layout.fillWidth: true
                }
                
                // Close button for popups
                AIcon {
                    visible: root.isPopup
                    icon: FontIcons.x
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
                text: root.summary
                font.bold: true
                font.pixelSize: 13
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            AText {
                text: root.body
                font.pixelSize: 12
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideRight
                Layout.fillWidth: true
                opacity: 0.9
            }

            Rectangle {
                visible: root.imageSource != ""
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                Layout.topMargin: 5
                radius: 4
                clip: true
                color: "transparent"
                
                Image {
                    anchors.fill: parent
                    source: root.imageSource
                    fillMode: Image.PreserveAspectCrop
                }
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
