pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

QtObject {
    readonly property list<string> moduleNames: ["search", "workspaces", "windowTitle", "clock", "tray", "notifications", "volume", "microphone", "brightness", "cpu", "memory", "network", "battery", "power"]

    function sourceFor(name: string): url {
        switch (name) {
        case "search":
            return Qt.resolvedUrl("../Modules/Bar/Modules/Search.qml");
        case "workspaces":
            return Qt.resolvedUrl("../Modules/Bar/Modules/Workspaces.qml");
        case "windowTitle":
            return Qt.resolvedUrl("../Modules/Bar/Modules/WindowTitle.qml");
        case "clock":
            return Qt.resolvedUrl("../Modules/Bar/Modules/Clock.qml");
        case "tray":
            return Qt.resolvedUrl("../Modules/Bar/Modules/Tray.qml");
        case "notifications":
            return Qt.resolvedUrl("../Modules/Bar/Modules/Notifications.qml");
        case "volume":
            return Qt.resolvedUrl("../Modules/Bar/Modules/Volume.qml");
        case "microphone":
            return Qt.resolvedUrl("../Modules/Bar/Modules/Microphone.qml");
        case "brightness":
            return Qt.resolvedUrl("../Modules/Bar/Modules/Brightness.qml");
        case "cpu":
            return Qt.resolvedUrl("../Modules/Bar/Modules/Cpu.qml");
        case "memory":
            return Qt.resolvedUrl("../Modules/Bar/Modules/Memory.qml");
        case "network":
            return Qt.resolvedUrl("../Modules/Bar/Modules/Network.qml");
        case "battery":
            return Qt.resolvedUrl("../Modules/Bar/Modules/Battery.qml");
        case "power":
            return Qt.resolvedUrl("../Modules/Bar/Modules/Power.qml");
        default:
            console.warn("Unknown bar module:", name);
            return "";
        }
    }
}
