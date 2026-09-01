pragma Singleton
import QtQuick

QtObject {
    readonly property list<string> moduleNames: ["workspaces", "windowTitle", "clock", "tray", "notifications", "volume", "microphone", "brightness", "cpu", "memory", "network", "battery", "power"]

    function sourceFor(name: string): url {
        switch (name) {
        case "workspaces":
            return Qt.resolvedUrl("../Modules/Bar/WorkspacesModule.qml");
        case "windowTitle":
            return Qt.resolvedUrl("../Modules/Bar/WindowTitleModule.qml");
        case "clock":
            return Qt.resolvedUrl("../Modules/Bar/ClockModule.qml");
        case "tray":
            return Qt.resolvedUrl("../Modules/Bar/TrayModule.qml");
        case "notifications":
            return Qt.resolvedUrl("../Modules/Bar/NotificationsModule.qml");
        case "volume":
            return Qt.resolvedUrl("../Modules/Bar/VolumeModule.qml");
        case "microphone":
            return Qt.resolvedUrl("../Modules/Bar/MicrophoneModule.qml");
        case "brightness":
            return Qt.resolvedUrl("../Modules/Bar/BrightnessModule.qml");
        case "cpu":
            return Qt.resolvedUrl("../Modules/Bar/CpuModule.qml");
        case "memory":
            return Qt.resolvedUrl("../Modules/Bar/MemModule.qml");
        case "network":
            return Qt.resolvedUrl("../Modules/Bar/NetworkModule.qml");
        case "battery":
            return Qt.resolvedUrl("../Modules/Bar/BatteryModule.qml");
        case "power":
            return Qt.resolvedUrl("../Modules/Bar/PowerModule.qml");
        default:
            console.warn("Unknown bar module:", name);
            return "";
        }
    }
}
