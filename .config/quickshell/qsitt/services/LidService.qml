pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

QtObject {
    id: root

    property bool lidClosed: false
    property bool stateKnown: false
    property var screensAtClose: []
    property bool clamshellActive: false
    property var switchedOffScreens: []
    property var pendingCommands: []

    function start(): void {
        initialState.running = true;
    }

    function isInternalScreen(name: string): bool {
        return /^(eDP|LVDS|DSI)(-|$)/i.test(name);
    }

    function hasExternalScreen(): bool {
        return Quickshell.screens.some(screen => !isInternalScreen(screen.name));
    }

    function updateLidState(closed: bool): void {
        if (stateKnown && lidClosed === closed)
            return;
        stateKnown = true;
        lidClosed = closed;
        if (closed) {
            screensAtClose = Quickshell.screens.map(screen => screen.name);
            clamshellActive = false;
            if (!hasExternalScreen() || (SettingsService.loaded && !SettingsService.lidClamshellMode))
                PowerService.lock();
            offDelay.restart();
        } else {
            offDelay.stop();
            suspendDelay.stop();
            clamshellActive = false;
            screensAtClose = [];
            const screens = switchedOffScreens;
            switchedOffScreens = [];
            for (const name of screens)
                enqueueOutput(name, "on");
        }
    }

    function enqueueOutput(name: string, action: string): void {
        enqueueCommand(["niri", "msg", "output", name, action]);
    }

    function enqueueCommand(command: var): void {
        pendingCommands = pendingCommands.concat([command]);
        runNextCommand();
    }

    function runNextCommand(): void {
        if (outputProcess.running || pendingCommands.length === 0)
            return;
        outputProcess.command = pendingCommands[0];
        pendingCommands = pendingCommands.slice(1);
        outputProcess.running = true;
    }

    readonly property Timer offDelay: Timer {
        interval: 300
        onTriggered: {
            if (!root.lidClosed)
                return;
            if (!SettingsService.loaded) {
                root.offDelay.restart();
                return;
            }
            const clamshell = SettingsService.lidClamshellMode && root.hasExternalScreen();
            root.clamshellActive = clamshell;
            if (!clamshell) {
                PowerService.lock();
                root.suspendDelay.restart();
                return;
            }
            const screens = root.screensAtClose.filter(name => root.isInternalScreen(name));
            root.switchedOffScreens = screens;
            for (const name of screens)
                root.enqueueOutput(name, "off");
            root.enqueueCommand(["niri", "msg", "action", "power-on-monitors"]);
        }
    }

    readonly property Timer suspendDelay: Timer {
        interval: 500
        onTriggered: {
            if (root.lidClosed && !(SettingsService.lidClamshellMode && root.hasExternalScreen()))
                PowerService.suspend();
        }
    }

    readonly property Connections screenConnection: Connections {
        target: Quickshell
        function onScreensChanged(): void {
            if (!root.lidClosed)
                return;
            if (root.clamshellActive && !root.hasExternalScreen()) {
                root.clamshellActive = false;
                PowerService.lock();
                root.suspendDelay.restart();
            } else if (root.suspendDelay.running && SettingsService.lidClamshellMode && root.hasExternalScreen()) {
                root.suspendDelay.stop();
                root.clamshellActive = true;
                root.enqueueCommand(["niri", "msg", "action", "power-on-monitors"]);
            }
        }
    }

    readonly property Process outputProcess: Process {
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                console.warn("Niri output command failed:", command.join(" "), exitCode);
            root.runNextCommand();
        }
    }

    readonly property Process initialState: Process {
        command: ["gdbus", "call", "--system", "--dest", "org.freedesktop.UPower",
                  "--object-path", "/org/freedesktop/UPower", "--method",
                  "org.freedesktop.DBus.Properties.Get", "org.freedesktop.UPower", "LidIsClosed"]
        stdout: StdioCollector {
            onStreamFinished: {
                const match = text.match(/<\s*(true|false)\s*>/);
                if (match && !root.stateKnown)
                    root.updateLidState(match[1] === "true");
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                console.warn("Could not read lid state from UPower");
        }
    }

    readonly property Process monitor: Process {
        command: ["gdbus", "monitor", "--system", "--dest", "org.freedesktop.UPower",
                  "--object-path", "/org/freedesktop/UPower"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const match = data.toString().match(/['"]LidIsClosed['"]:\s*<\s*(true|false)\s*>/);
                if (match)
                    root.updateLidState(match[1] === "true");
            }
        }
        onExited: root.restartMonitor.start()
    }

    readonly property Timer restartMonitor: Timer {
        interval: 1000
        onTriggered: {
            root.initialState.running = true;
            root.monitor.running = true;
        }
    }

}
