//@ pragma UseQApplication
//@ pragma AppId kalumiru
import QtQuick
import Quickshell
import qs.modules.bar
import qs.modules.controlcenter
import qs.modules.debug
import qs.modules.lock
import qs.modules.notifications
import qs.modules.osd
import qs.modules.powermenu
import qs.modules.qrscanner
import qs.modules.search
import qs.services

ShellRoot {
    Component.onCompleted: {
        DesktopThemeService.sync();
        LidService.start();
    }

    Bar {
        id: mainBar
    }
    ControlCenterIpc {}
    ControlCenter {
        bar: mainBar
    }
    Lock {}
    Notifications {}
    NotificationPanel {
        bar: mainBar
    }
    Osd {}
    DebugWindow {}
    QrScanner {}
    Search {
        bar: mainBar
    }
    SearchIpc {}
    ThemeIpc {}
    PowerMenu {
        bar: mainBar
    }
}
