import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Notifications
import qs.ui.widgets
import qs.ui.theme
import qs.services

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
    implicitHeight: Math.min(layout.implicitHeight + 32, 440)
    height: implicitHeight // Max height cap
    color: Theme.surfaceContainer
    radius: 16
    border.color: Theme.outlineVariant
    border.width: 1
    clip: true

    signal closed

    function resolveIcon(icon, fallback) {
        if (!icon)
            return fallback ? resolveIcon(fallback) : "";
        if (icon.indexOf("/") >= 0 || icon.indexOf("file://") >= 0 || icon.indexOf("image://") >= 0)
            return icon;
        return Quickshell.iconPath(icon, fallback || "");
    }

    Timer {
        interval: 5000
        running: root.isPopup && !hoverArea.containsMouse
        repeat: false
        onTriggered: root.closed()
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 16
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
                source: root.appIconSource ? resolveIcon(root.appIconSource) : root.iconSource ? resolveIcon(root.iconSource) : ""
                fillMode: Image.PreserveAspectFit
                onStatusChanged: if (status == Image.Error)
                    visible = false
            }

            QsIcon {
                anchors.centerIn: parent
                icon: Icons.bell
                size: 26
                color: Theme.primary
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
                Text {
                    color: Theme.text
                    textFormat: Text.PlainText
                    font.family: Theme.fontFamily
                    text: root.appName
                    font.pixelSize: 10
                    opacity: 0.7
                    Layout.fillWidth: true
                }

                // Close button for popups
                QsIcon {
                    visible: true
                    icon: Icons.x
                    size: 16
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.closed();
                        }
                    }
                }
            }

            Text {
                color: Theme.text
                textFormat: Text.PlainText
                font.family: Theme.fontFamily
                text: root.summary
                font.bold: true
                font.pixelSize: 13
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                color: Theme.text
                textFormat: Text.PlainText
                font.family: Theme.fontFamily
                text: root.body
                font.pixelSize: 12
                wrapMode: Text.Wrap
                maximumLineCount: root.isPopup ? 4 : 12
                elide: Text.ElideRight
                Layout.fillWidth: true
                opacity: 0.9
            }

            Flow {
                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight
                spacing: 6
                Repeater {
                    model: root.notification ? root.notification.actions : []
                    delegate: QsButton {
                        required property var modelData
                        text: modelData.text
                        onClicked: {
                            modelData.invoke();
                            root.closed();
                        }
                    }
                }
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

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}
