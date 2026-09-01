import QtQuick
import Quickshell.Bluetooth

QtObject {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: adapter && adapter.devices ? adapter.devices.values : []
    readonly property bool available: adapter !== null
    readonly property bool enabled: available && adapter.enabled
    readonly property bool discovering: available && adapter.discovering

    function setEnabled(enabled) {
        if (adapter)
            adapter.enabled = enabled;
    }

    function setDiscovering(discovering) {
        if (adapter)
            adapter.discovering = discovering;
    }
}
