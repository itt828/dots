//@ pragma UseQApplication
//@ pragma AppId qsitt
import QtQuick
import Quickshell
import qs.Features.Bar
import qs.Features.ControlCenter
import qs.Features.Lock
import qs.Features.Notifications
import qs.Features.PowerMenu
import qs.Features.QrScanner
import qs.Features.Search

ShellRoot {
    Bar {}
    ControlCenter {}
    Lock {}
    Notifications {}
    QrScanner {}
    Search {}
    PowerMenu {}
}
