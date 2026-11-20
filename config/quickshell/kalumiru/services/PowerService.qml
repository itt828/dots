pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io

QtObject {
    property bool visible: false
    property bool locked: false
    property string outputName: ""
    property point upperAnchor
    property point lowerAnchor

    function toggleAt(output: string, button: Item): void {
        if (visible && outputName === output) {
            visible = false;
            return;
        }
        SearchService.close();
        upperAnchor = button.mapToItem(null, button.width, 0);
        lowerAnchor = button.mapToItem(null, button.width, button.height);
        ControlCenterService.visible = false;
        NotificationService.panelVisible = false;
        outputName = output;
        visible = true;
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

    readonly property BackendProcess _shutdownProcess: BackendProcess {
        arguments: ["power", "poweroff"]
    }
    readonly property BackendProcess _rebootProcess: BackendProcess {
        arguments: ["power", "reboot"]
    }
    readonly property BackendProcess _suspendProcess: BackendProcess {
        arguments: ["power", "suspend"]
    }
    readonly property BackendProcess _logoutProcess: BackendProcess {
        arguments: ["power", "logout"]
    }
}
