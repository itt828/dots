import QtQuick
import Quickshell
import Quickshell.Wayland
import "../Services"
import "./LockScreen"

Scope {
    required property var powerContext

    LockContext {
        id: lockContext
        onUnlocked: {
            console.log("Unlock requested");
            powerContext.locked = false;
        }
    }

    WlSessionLock {
        id: lock
        locked: powerContext.locked

        onLockedChanged: {
            console.log("WlSessionLock state changed:", locked);
            if (locked !== powerContext.locked) {
                powerContext.locked = locked;
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
