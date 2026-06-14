//@ pragma UseQApplication
import QtQuick
import Quickshell
import "Widgets"
import "Services"

ShellRoot {
    Provider { id: services }
    Bar { services: services }
    SimpleBar { workspaceStore: services.workspaces }
    Dashboard { dashboardContext: services.dashboard }
    Notification { notificationStore: services.notifications }
    PowerMenu { powerContext: services.power }
    LockScreen { powerContext: services.power }

    // IpcHandler {
    //     target: "shell"
    //     function lock(): void {
    //         console.log("IPC lock request received");
    //         services.power.lock();
    //     }
    // }
}
