//@ pragma UseQApplication
//@ pragma AppId qsitt
import QtQuick
import Quickshell
import qs.modules.bar
import qs.modules.controlcenter
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

    Bar {}
    ControlCenterIpc {}
    ControlCenter {}
    Lock {}
    Notifications {}
    NotificationPanel {}
    Osd {}
    QrScanner {}
    Search {}
    SearchIpc {}
    ThemeIpc {}
    PowerMenu {}
}
