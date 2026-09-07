import Notifd from "gi://AstalNotifd"
import { createBinding } from "gnim"

export const notificationService = Notifd.get_default()
export const notifications = createBinding(notificationService, "notifications")
export const doNotDisturb = createBinding(notificationService, "dontDisturb")
