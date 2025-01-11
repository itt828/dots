import { App, Gdk } from "astal/gtk3"
import { bind } from "astal"
import AstalTray from "gi://AstalTray"

export const Tray = () => {
  const tray = AstalTray.get_default()
  return <box className="Tray">
    {bind(tray, "items").as(items => items.map(item => (
      <menubutton
        tooltipMarkup={bind(item, "tooltipMarkup")}
        usePopover={false}
        actionGroup={bind(item, "action-group").as(ag => ["dbusmenu", ag])}
        menuModel={bind(item, "menu-model")}>
        <icon gicon={bind(item, "gicon")} />
      </menubutton>
    )))}
  </box>
}
