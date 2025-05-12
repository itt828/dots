import { bind, Variable } from "astal"
import AstalNotifd from "gi://AstalNotifd"

export const Notification = () => {
  const notifd = AstalNotifd.get_default()

  const notifications = bind(notifd, "notifications")

  return <box className="Notification" spacing={8}>
    <label label=" " />
    {notifications.as((notifications) =>
      <label label={String(notifications.length)} />
    )}
  </box>
}
