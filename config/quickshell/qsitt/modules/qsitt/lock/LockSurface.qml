import qs.services
import qs.modules.common.theme
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Services.UPower
import qs.modules.common.widgets

Rectangle {
    id: root
    required property LockService context
    readonly property var battery: UPower.devices.values.find(device => device.isLaptopBattery && device.isPresent) ?? null
    readonly property var mediaPlayer: Mpris.players.values.find(player => player.isPlaying && player.canTogglePlaying)
        ?? Mpris.players.values.find(player => player.canTogglePlaying) ?? null

    color: Theme.text

    Rectangle {
        visible: root.battery !== null
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 28
        width: batteryLabel.implicitWidth + 24
        height: 36
        radius: 18
        color: Theme.withAlpha(Theme.surface, 0.12)

        QsIconLabel {
            id: batteryLabel
            anchors.centerIn: parent
            color: root.battery && root.battery.percentage < 0.2
                && root.battery.state === UPowerDeviceState.Discharging ? Theme.danger : Theme.surface
            icon: {
                if (!root.battery)
                    return "";
                if (root.battery.state === UPowerDeviceState.Charging)
                    return Icons.batteryCharging;
                if (root.battery.percentage > 0.9)
                    return Icons.batteryFull;
                if (root.battery.percentage > 0.7)
                    return Icons.batteryHigh;
                if (root.battery.percentage > 0.3)
                    return Icons.batteryMedium;
                return Icons.batteryLow;
            }
            text: root.battery ? Math.round(root.battery.percentage * 100) + "% " +
                (root.battery.state === UPowerDeviceState.Charging ? "充電中" :
                 root.battery.state === UPowerDeviceState.FullyCharged ? "満充電" :
                 root.battery.state === UPowerDeviceState.Discharging ? "放電中" : "バッテリー") : ""
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 50

        // Clock
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 0

            Text {
            font.family: Theme.fontFamily
                id: timeLabel
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 96
                color: Theme.surface
                verticalAlignment: Text.AlignVCenter

                text: Qt.formatTime(new Date(), "HH:mm")

                Timer {
                    running: true
                    repeat: true
                    interval: 1000
                    onTriggered: timeLabel.text = Qt.formatTime(new Date(), "HH:mm")
                }
            }

            Text {
            font.family: Theme.fontFamily
                id: dateLabel
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 24
                color: Theme.outline
                verticalAlignment: Text.AlignVCenter

                text: Qt.formatDate(new Date(), "dddd, MMMM d")

                Timer {
                    running: true
                    repeat: true
                    interval: 60000 // Update every minute
                    onTriggered: dateLabel.text = Qt.formatDate(new Date(), "dddd, MMMM d")
                }
            }
        }

        // Login Box
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 15

            TextField {
                id: passwordBox

                implicitWidth: 300
                implicitHeight: 40
                padding: 10
                horizontalAlignment: TextInput.AlignHCenter

                background: Rectangle {
                    color: Theme.surface
                    radius: 20
                    opacity: 0.2
                    border.color: passwordBox.activeFocus ? "white" : "transparent"
                    border.width: 1
                }

                color: Theme.surface
                focus: true
                enabled: !root.context.unlockInProgress
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhSensitiveData

                placeholderText: "Password"
                placeholderTextColor: "#88ffffff"

                // Update the text in the context when the text in the box changes.
                onTextChanged: root.context.currentText = this.text

                // Try to unlock when enter is pressed.
                onAccepted: root.context.tryUnlock(passwordBox.text)

                // Update the text in the box to match the text in the context.
                Connections {
                    target: root.context
                    function onCurrentTextChanged() {
                        passwordBox.text = root.context.currentText;
                    }
                }
            }

            Text {
            font.family: Theme.fontFamily
                visible: root.context.showFailure
                text: "Incorrect password"
                color: Theme.danger
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 156
            implicitHeight: 44
            radius: 22
            color: Theme.surface
            opacity: root.mediaPlayer ? 1 : 0.5

            RowLayout {
                anchors.centerIn: parent
                spacing: 8

                QsIcon {
                    icon: root.mediaPlayer && root.mediaPlayer.isPlaying ? Icons.mediaPause : Icons.mediaPlay
                    size: 18
                    color: Theme.text
                }

                Text {
                    text: root.mediaPlayer ? (root.mediaPlayer.isPlaying ? "一時停止" : "再生") : "メディアなし"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.mediaPlayer !== null
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    root.mediaPlayer.togglePlaying();
                    passwordBox.forceActiveFocus();
                }
            }
        }
    }
}
