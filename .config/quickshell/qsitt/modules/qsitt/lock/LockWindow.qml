//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

ShellRoot {
    Connections {
        target: LockService
        function onUnlocked() {
            // Unlock the screen before exiting, or the compositor will display a
            // fallback lock you can't interact with.
            lock.locked = false;

            Qt.quit();
        }
    }

    WlSessionLock {
        id: lock

        // Lock the session immediately when quickshell starts.
        locked: true

        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: LockService
            }
        }
    }
}
