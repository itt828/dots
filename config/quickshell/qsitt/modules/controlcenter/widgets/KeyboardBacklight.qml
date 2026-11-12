import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.ui.theme
import qs.services

Rectangle {
    id: root

    property int level: 0
    property int maxLevel: 0
    property bool available: false
    property bool busy: false

    Layout.fillWidth: true
    implicitHeight: 54
    radius: Theme.radius
    color: Theme.surface

    function refresh(): void {
        if (!readProcess.running)
            readProcess.running = true;
    }

    function toggle(): void {
        if (!available || busy)
            return;
        busy = true;
        setProcess.command = ["brightnessctl", "-d", "tpacpi::kbd_backlight", "set",
                              String((level + 1) % (maxLevel + 1))];
        setProcess.running = true;
    }

    readonly property Process readProcess: Process {
        command: ["brightnessctl", "-m", "-d", "tpacpi::kbd_backlight", "info"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(",");
                if (parts.length < 5)
                    return;
                const current = parseInt(parts[2], 10);
                const maximum = parseInt(parts[4], 10);
                if (!isNaN(current) && !isNaN(maximum) && maximum > 0) {
                    root.level = current;
                    root.maxLevel = maximum;
                    root.available = true;
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                root.available = false;
        }
    }

    readonly property Process setProcess: Process {
        onExited: (exitCode, exitStatus) => {
            root.busy = false;
            if (exitCode !== 0)
                console.warn("Could not set keyboard backlight:", exitCode);
            root.refresh();
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: ControlCenterService.visible
        onTriggered: root.refresh()
    }

    Connections {
        target: ControlCenterService
        function onVisibleChanged(): void {
            if (ControlCenterService.visible)
                root.refresh();
        }
    }

    Component.onCompleted: refresh()

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: "キーボードバックライト"
                color: Theme.text
                font.family: Theme.fontFamily
            }

            Text {
                text: "クリックで オフ → 弱 → 強 を切り替え"
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        Text {
            text: !root.available ? "利用不可" : root.level === 0 ? "オフ" : root.level === root.maxLevel ? "強" : "弱"
            color: root.available && root.level > 0 ? Theme.accent : Theme.textSecondary
            font.family: Theme.fontFamily
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.available && !root.busy
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.toggle()
    }
}
