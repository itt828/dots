pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import Quickshell.Bluetooth

QtObject {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: adapter && adapter.devices ? adapter.devices.values : []
    readonly property bool available: adapter !== null
    readonly property bool enabled: available && adapter.enabled
    readonly property bool discovering: available && adapter.discovering
    property var pairingDevice: null
    property string prompt: ""
    property string pairingCode: ""
    property string pairingStatus: ""
    readonly property bool pairing: agent.running

    function pair(device: var): void {
        if (!device || device.paired || pairing)
            return;
        pairingDevice = device;
        pairingStatus = "ペアリング中…";
        prompt = "";
        pairingCode = "";
        agent.execute(["bluetooth", "pair", device.dbusPath]);
    }

    function answer(value: var): void {
        if (pairing && prompt && prompt !== "display") {
            agent.write(JSON.stringify({
                answer: value
            }) + "\n");
            prompt = "";
            pairingCode = "";
        }
    }

    function cancelPairing(): void {
        if (pairing) {
            agent.write('{"cancel":true}\n');
            pairingStatus = "ペアリングをキャンセルしました";
            prompt = "";
            pairingCode = "";
        }
    }

    readonly property BackendProcess agent: BackendProcess {
        stdinEnabled: true
        stdout: SplitParser {
            onRead: line => {
                try {
                    const result = JSON.parse(line);
                    if (["confirm", "authorize", "pin", "passkey", "display"].includes(result.kind)) {
                        root.prompt = result.kind;
                        root.pairingCode = result.code ?? "";
                    } else {
                        root.prompt = "";
                        root.pairingCode = "";
                        if (result.kind !== "waiting")
                            root.pairingStatus = result.kind === "success" ? "ペアリングが完了しました" : result.kind === "cancelled" ? "ペアリングをキャンセルしました" : "ペアリングに失敗しました";
                    }
                } catch (_) {
                    root.pairingStatus = "ペアリングの応答を読み取れませんでした";
                }
            }
        }
        onExited: code => {
            if (code === 20 && root.pairingDevice && root.pairingStatus === "ペアリング中…") {
                root.pairingStatus = "システムの Bluetooth ペアリングを使用します";
                root.pairingDevice.pair();
            } else if (root.pairingStatus === "ペアリング中…") {
                root.pairingStatus = code === 0 ? "ペアリングが完了しました" : "ペアリングに失敗しました";
            }
            root.prompt = "";
            root.pairingCode = "";
            root.pairingDevice = null;
        }
    }

    readonly property Timer scanTimeout: Timer {
        interval: 20000
        onTriggered: root.setDiscovering(false)
    }

    function setEnabled(enabled) {
        if (adapter) {
            if (!enabled)
                cancelPairing();
            adapter.enabled = enabled;
        }
    }

    function setDiscovering(discovering) {
        if (adapter) {
            adapter.discovering = discovering;
            if (discovering)
                scanTimeout.restart();
            else
                scanTimeout.stop();
        }
    }
}
