//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

ShellRoot {
    Connections {
        target: LockService
        function onUnlocked() {
            lock.locked = false;

            Qt.quit();
        }
    }

    WlSessionLock {
        id: lock

        locked: true

        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: LockService
            }
        }
    }
}
