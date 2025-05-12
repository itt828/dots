import { bind } from "astal"
import AstalTray from "gi://AstalTray"

export const Tray = () => {
    const tray = AstalTray.get_default()
    return <box cssName="Tray">
        {bind(tray, "items").as(items => items.map(item => (
            <menubutton
                tooltipMarkup={bind(item, "tooltipMarkup")}
                usePopover={false}
                actionGroup={bind(item, "action-group").as(ag => ["dbusmenu", ag])}
                menuModel={bind(item, "menu-model")}>
                <image gicon={bind(item, "gicon")} />
            </menubutton>
        )))}
    </box>
}
