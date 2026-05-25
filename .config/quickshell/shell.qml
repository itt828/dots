//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import "Modules"
import "Services"

ShellRoot {
    Bar {}
    Dashboard {}
    NotificationPopups {}
    PowerMenu {}
    ScreenLock {}

    IpcHandler {
        target: "shell"
        function lock(): void {
            console.log("IPC lock request received");
            PowerContext.lock();
        }
    }
}
