//@ pragma UseQApplication
//@ pragma AppId qsitt
import QtQuick
import Quickshell
import qs.modules.qsitt.bar
import qs.modules.qsitt.controlcenter
import qs.modules.qsitt.lock
import qs.modules.qsitt.notifications
import qs.modules.qsitt.powermenu
import qs.modules.qsitt.qrscanner
import qs.modules.qsitt.search
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
    QrScanner {}
    Search {}
    SearchIpc {}
    ThemeIpc {}
    PowerMenu {}
}
