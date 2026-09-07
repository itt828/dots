import Tray from "gi://AstalTray"
import { createBinding } from "gnim"

export const trayService = Tray.get_default()
export const trayItems = createBinding(trayService, "items")
