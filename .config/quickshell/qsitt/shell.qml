//@ pragma UseQApplication
//@ pragma AppId qsitt
import QtQuick
import Quickshell
import qs.Modals.PowerMenu
import qs.Modules.Bar
import qs.Modules.Bar.Widgets as BarWidgets
import qs.Modules.ControlCenter
import qs.Modules.Lock
import qs.Modules.Notifications
import qs.Modules.QrScanner
import qs.Modules.Search

ShellRoot {
    Bar {}
    ControlCenter {}
    Lock {}
    Notifications {}
    QrScanner {}
    Search {}
    PowerMenu {}
}
