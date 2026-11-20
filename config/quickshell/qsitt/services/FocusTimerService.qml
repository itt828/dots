pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

QtObject {
    id: root

    property int duration: 1500
    property int remaining: duration
    property real deadline: 0
    property bool running: false
    property bool stopwatchRunning: false
    property real stopwatchStarted: 0
    property real stopwatchMs: 0

    function formatTime(totalSeconds: real): string {
        const seconds = Math.max(0, Math.floor(totalSeconds));
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        const mm = String(minutes).padStart(2, "0");
        const ss = String(seconds % 60).padStart(2, "0");
        return hours > 0 ? String(hours).padStart(2, "0") + ":" + mm + ":" + ss : mm + ":" + ss;
    }

    function setDuration(minutes: int): void {
        running = false;
        duration = minutes * 60;
        remaining = duration;
    }

    function toggle(): void {
        if (running) {
            remaining = Math.max(1, Math.ceil((deadline - Date.now()) / 1000));
            running = false;
        } else {
            if (remaining <= 0)
                remaining = duration;
            deadline = Date.now() + remaining * 1000;
            running = true;
        }
    }

    function toggleStopwatch(): void {
        const now = Date.now();
        if (stopwatchRunning)
            stopwatchMs += Math.max(0, now - stopwatchStarted);
        stopwatchStarted = now;
        stopwatchRunning = !stopwatchRunning;
    }

    function resetStopwatch(): void {
        stopwatchRunning = false;
        stopwatchMs = 0;
    }

    readonly property Timer timer: Timer {
        interval: 100
        running: root.running || root.stopwatchRunning
        repeat: true
        onTriggered: {
            const now = Date.now();
            if (root.running) {
                root.remaining = Math.max(0, Math.ceil((root.deadline - now) / 1000));
                if (root.remaining === 0) {
                    root.running = false;
                    ControlCenterService.notifyTimer();
                }
            }
            if (root.stopwatchRunning) {
                root.stopwatchMs += Math.max(0, now - root.stopwatchStarted);
                root.stopwatchStarted = now;
            }
        }
    }
}
