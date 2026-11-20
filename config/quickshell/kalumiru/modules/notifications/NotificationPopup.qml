import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Notifications
import qs.ui.widgets
import qs.ui.theme
import qs.services

QsPopupSurface {
    id: root

    property var notification
    property bool isPopup: true
    animated: isPopup
    entryX: Theme.toastSlide
    entryY: -4
    closedScale: 0.975

    property bool countdownVisible: true
    readonly property int duration: {
        const timeout = notification?.expireTimeout ?? -1;
        if (timeout === 0 || (timeout < 0 && notification?.urgency === NotificationUrgency.Critical))
            return 0;
        return timeout > 0 ? timeout : SettingsService.notificationSeconds * 1000;
    }
    property real remaining: duration
    readonly property bool paused: hoverArea.containsMouse || containsFocus(Window.window?.activeFocusItem ?? null)

    function containsFocus(item: Item): bool {
        while (item) {
            if (item === root)
                return true;
            item = item.parent;
        }
        return false;
    }

    onDurationChanged: remaining = duration

    property string appName: (notification && notification.appName) ? notification.appName : "System"
    property string summary: (notification && notification.summary) ? notification.summary : ""
    property string body: (notification && notification.body) ? notification.body : ""
    property string appIconSource: ""
    property string iconSource: ""
    property string imageSource: ""

    width: 300
    implicitHeight: Math.min(content.implicitHeight + 28, 440)
    height: implicitHeight
    color: isPopup ? Theme.surface : Theme.bgTertiary
    radius: 16
    border.color: Theme.glassOutline
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
        id: countdown
        property real lastTick: 0

        interval: 50
        running: root.ready && root.shown && root.isPopup && root.duration > 0 && root.countdownVisible && !root.paused
        repeat: true
        onRunningChanged: if (running)
            lastTick = Date.now()
        onTriggered: {
            const now = Date.now();
            root.remaining = Math.max(0, root.remaining - Math.max(0, now - lastTick));
            lastTick = now;
            if (root.remaining === 0)
                root.closed();
        }
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8
        RowLayout {
            id: layout
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            Rectangle {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: 8
                color: "transparent"

                Image {
                    id: iconImage
                    anchors.fill: parent
                    source: root.appIconSource ? resolveIcon(root.appIconSource) : root.iconSource ? resolveIcon(root.iconSource) : ""
                    fillMode: Image.PreserveAspectFit
                    onStatusChanged: if (status == Image.Error)
                        visible = false
                }

                QsIcon {
                    anchors.centerIn: parent
                    icon: Icons.bell
                    size: 26
                    color: Theme.mustard800
                    visible: iconImage.status == Image.Error || iconImage.source == "" || iconImage.status == Image.Null
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        color: Theme.textPrimary
                        textFormat: Text.PlainText
                        font.family: Theme.fontFamily
                        text: root.appName
                        font.pixelSize: 10
                        opacity: 0.7
                        Layout.fillWidth: true
                    }

                    QsButton {
                        icon: Icons.x
                        implicitWidth: 24
                        implicitHeight: 24
                        variant: QsButton.Ghost
                        toolTip: "通知を閉じる"
                        Accessible.name: toolTip
                        onClicked: root.closed()
                    }
                }

                QsMarqueeText {
                    color: Theme.textPrimary
                    textFormat: Text.PlainText
                    font.family: Theme.fontFamily
                    text: root.summary
                    font.bold: true
                    font.pixelSize: 13
                    Layout.fillWidth: true
                }

                QsMarqueeText {
                    color: Theme.textPrimary
                    textFormat: Text.PlainText
                    font.family: Theme.fontFamily
                    text: root.body
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    maximumLineCount: root.isPopup ? 4 : 12
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

        QsProgressBar {
            visible: root.isPopup && root.duration > 0
            Layout.fillWidth: true
            to: root.duration
            value: root.remaining
            animationDuration: Theme.motionEnabled && !root.paused ? countdown.interval : 0
            animationEasing: Easing.Linear
            opacity: root.paused ? 0.65 : 1
            Accessible.role: Accessible.ProgressBar
            Accessible.name: "通知が消えるまでの残り時間"
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}
