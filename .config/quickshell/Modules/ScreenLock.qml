import QtQuick
import Quickshell
import Quickshell.Wayland
import "../Services"
import "./Lock"

Scope {
    LockContext {
        id: lockContext
        onUnlocked: {
            console.log("Unlock requested");
            PowerContext.locked = false;
        }
    }

    WlSessionLock {
        id: lock
        locked: PowerContext.locked

        onLockedChanged: {
            console.log("WlSessionLock state changed:", locked);
            if (locked !== PowerContext.locked) {
                PowerContext.locked = locked;
            }
        }

        surface: WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }
}
