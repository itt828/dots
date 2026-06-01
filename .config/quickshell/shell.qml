//@ pragma UseQApplication
import QtQuick
import Quickshell
import "Widgets"
import "Services"

ShellRoot {
    Scope {
        id: services
        property var niri: NiriService
    }

    Bar {}
    SimpleBar {}
    Dashboard {}
    Notification {}
    PowerMenu {}
    LockScreen {}

    // IpcHandler {
    //     target: "shell"
    //     function lock(): void {
    //         console.log("IPC lock request received");
    //         PowerContext.lock();
    //     }
    // }
}
