pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io

QtObject {
    property bool visible: false
    property bool locked: false

    function toggle() {
        visible = !visible;
    }

    function lock() {
        locked = true;
    }

    function powerOff(): void {
        visible = false;
        _shutdownProcess.running = true;
    }

    function reboot(): void {
        visible = false;
        _rebootProcess.running = true;
    }

    function suspend(): void {
        visible = false;
        lock();
        _suspendProcess.running = true;
    }

    function logout(): void {
        visible = false;
        _logoutProcess.running = true;
    }

    readonly property Process _shutdownProcess: Process { command: ["systemctl", "poweroff"] }
    readonly property Process _rebootProcess: Process { command: ["systemctl", "reboot"] }
    readonly property Process _suspendProcess: Process { command: ["systemctl", "suspend"] }
    readonly property Process _logoutProcess: Process { command: ["loginctl", "terminate-user", ""] }
}
