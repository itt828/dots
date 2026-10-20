pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

Scope {
    Connections {
        target: LockService
        function onUnlocked() {
            console.log("Unlock requested");
            PowerService.locked = false;
        }
    }

    WlSessionLock {
        id: lock
        locked: PowerService.locked

        onLockedChanged: {
            console.log("WlSessionLock state changed:", locked);
            if (locked !== PowerService.locked) {
                PowerService.locked = locked;
            }
        }

        surface: WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: LockService
            }
        }
    }
}
