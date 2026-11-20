pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property var capabilities: ({})
    property string wallpaperStatus: ""
    property string nightStatus: ""
    readonly property bool canSetWallpaper: capabilities.wallpaper ?? false
    readonly property bool canSetNight: capabilities.night ?? false
    readonly property bool nightEnabled: night.processId > 0

    function setWallpaper(url: url): void {
        if (!canSetWallpaper || wallpaper.running)
            return;
        const localUrl = url.toString();
        if (!localUrl.startsWith("file:///"))
            return;
        wallpaperStatus = "壁紙を変更中…";
        wallpaper.exec(["awww", "img", "--transition-type", "fade", "--", decodeURIComponent(localUrl.slice(7))]);
    }

    function toggleNight(): void {
        if (night.running) {
            night.signal(15); // Releasing the gamma-control object restores the default.
            return;
        }
        if (canSetNight) {
            nightStatus = "";
            night.running = true;
        }
    }

    readonly property BackendProcess probe: BackendProcess {
        running: true
        arguments: ["tool", "appearance-capabilities"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.capabilities = JSON.parse(text);
                } catch (_) {
                    root.capabilities = {};
                }
            }
        }
    }

    readonly property Process wallpaper: Process {
        onExited: code => root.wallpaperStatus = code === 0 ? "壁紙を変更しました" : "壁紙を変更できませんでした。awww-daemon を確認してください。"
    }

    readonly property Process night: Process {
        command: ["wlsunset", "-t", "3500", "-T", "3501"]
        onExited: code => {
            if (code !== 0 && code !== 15)
                root.nightStatus = "このセッションでは夜間モードを開始できませんでした";
        }
    }
}
