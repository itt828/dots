import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common.theme

ColumnLayout {
    id: root

    required property var controlCenterService

    property int timerDuration: 300
    property int timerRemaining: timerDuration
    property double timerDeadline: 0
    property bool timerRunning: false
    property bool stopwatchRunning: false
    property double stopwatchStartedAt: 0
    property double stopwatchAccumulated: 0

    function formatTime(totalSeconds) {
        const seconds = Math.max(0, Math.floor(totalSeconds));
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        const rest = seconds % 60;
        const mm = String(minutes).padStart(2, "0");
        const ss = String(rest).padStart(2, "0");
        return hours > 0 ? String(hours).padStart(2, "0") + ":" + mm + ":" + ss : mm + ":" + ss;
    }

    function setTimer(minutes) {
        timerRunning = false;
        timerDuration = minutes * 60;
        timerRemaining = timerDuration;
    }

    spacing: 10

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: timerContent.implicitHeight + 24
        radius: 8
        color: Theme.surface

        ColumnLayout {
            id: timerContent
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: 12
            }
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                Text {
            font.family: Theme.fontFamily
                    text: "タイマー"
                    color: Theme.text
                    font.bold: true
                }
                Item {
                    Layout.fillWidth: true
                }
                Text {
            font.family: Theme.fontFamily
                    text: root.formatTime(root.timerRemaining)
                    color: root.timerRunning ? Theme.accent : Theme.text
                    font.bold: true
                    font.pointSize: 16
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: [1, 5, 10]
                    Rectangle {
                        required property int modelData
                        Layout.fillWidth: true
                        height: 28
                        radius: 6
                        color: !root.timerRunning && root.timerDuration === modelData * 60 ? Theme.primaryContainer : Theme.surfaceVariant
                        Text {
            font.family: Theme.fontFamily
                            anchors.centerIn: parent
                            text: modelData + "分"
                            color: Theme.text
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: !root.timerRunning
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: root.setTimer(modelData)
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    radius: 6
                    color: root.timerRunning ? "#ffcdd2" : "#c8e6c9"
                    Text {
            font.family: Theme.fontFamily
                        anchors.centerIn: parent
                        text: root.timerRunning ? "停止" : (root.timerRemaining < root.timerDuration ? "再開" : "開始")
                        color: Theme.text
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.timerRunning) {
                                root.timerRunning = false;
                            } else {
                                if (root.timerRemaining <= 0)
                                    root.timerRemaining = root.timerDuration;
                                root.timerDeadline = Date.now() + root.timerRemaining * 1000;
                                root.timerRunning = true;
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: stopwatchContent.implicitHeight + 24
        radius: 8
        color: Theme.surface

        RowLayout {
            id: stopwatchContent
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: 12
            }
            spacing: 8

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
            font.family: Theme.fontFamily
                    text: "ストップウォッチ"
                    color: Theme.text
                    font.bold: true
                }
                Text {
            font.family: Theme.fontFamily
                    text: root.formatTime(root.stopwatchAccumulated / 1000)
                    color: root.stopwatchRunning ? Theme.accent : Theme.text
                    font.bold: true
                    font.pointSize: 16
                }
            }

            Rectangle {
                width: 52
                height: 30
                radius: 6
                color: root.stopwatchRunning ? "#ffcdd2" : "#c8e6c9"
                Text {
            font.family: Theme.fontFamily
                    anchors.centerIn: parent
                    text: root.stopwatchRunning ? "停止" : "開始"
                    color: Theme.text
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.stopwatchRunning) {
                            root.stopwatchAccumulated += Date.now() - root.stopwatchStartedAt;
                            root.stopwatchRunning = false;
                        } else {
                            root.stopwatchStartedAt = Date.now();
                            root.stopwatchRunning = true;
                        }
                    }
                }
            }

            Rectangle {
                width: 52
                height: 30
                radius: 6
                color: Theme.surfaceVariant
                Text {
            font.family: Theme.fontFamily
                    anchors.centerIn: parent
                    text: "リセット"
                    color: Theme.text
                    font.pointSize: 9
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.stopwatchRunning = false;
                        root.stopwatchAccumulated = 0;
                    }
                }
            }
        }
    }

    Timer {
        interval: 100
        running: root.timerRunning || root.stopwatchRunning
        repeat: true
        onTriggered: {
            const now = Date.now();
            if (root.timerRunning) {
                root.timerRemaining = Math.max(0, Math.ceil((root.timerDeadline - now) / 1000));
                if (root.timerRemaining === 0) {
                    root.timerRunning = false;
                    root.controlCenterService.notifyTimer();
                }
            }
            if (root.stopwatchRunning)
                root.stopwatchAccumulated += now - root.stopwatchStartedAt;
            if (root.stopwatchRunning)
                root.stopwatchStartedAt = now;
        }
    }

}
