import QtQuick
import qs.Modals.PowerMenu
import qs.Modules.Bar
import qs.Modules.Bar.Widgets as BarWidgets
import qs.Modules.ControlCenter
import qs.Modules.Lock
import qs.Modules.Notifications
import qs.Modules.QrScanner

Item {
    Bar {}
    ControlCenter {}
    Lock {}
    Notifications {}
    QrScanner {}
    PowerMenu {}
}
