import { bind } from "astal"
import { App, Astal, Gdk, Gtk } from "astal/gtk3"
import AstalNotifd from "gi://AstalNotifd"

export const Notifications = (gdkmonitor: Gdk.Monitor) => {
  const notifd = AstalNotifd.get_default()
  const notifications = bind(notifd, "notifications")

  return <window
    className="Notifications"
    gdkmonitor={gdkmonitor}
    exclusivity={Astal.Exclusivity.IGNORE}
    anchor={Astal.WindowAnchor.TOP
      | Astal.WindowAnchor.RIGHT}
    application={App}>
    <box spacing={8} vertical>
      {
        notifications.as((notifs) => notifs.map(notif => {
          return <box vertical>
            <label label={notif.app_name} />
            <label label={notif.summary} />
            <label label={notif.body} />
          </box>
        }))
      }
    </box>
  </window >
}
