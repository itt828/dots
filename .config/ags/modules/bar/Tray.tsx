import { Gdk, Gtk } from "ags/gtk4"
import { For } from "gnim"

import { trayItems } from "../../services"
import { pointerCursor, setPointerCursor } from "../common/cursor"

function TrayItem({ item }: { item: any }) {
  const icon = <image pixelSize={16} gicon={item.gicon} />
  const tooltip = item.tooltip_markup || item.title

  if (!item.menu_model) {
    return (
      <button {...pointerCursor} class="tray-item" tooltipMarkup={tooltip}>
        <Gtk.GestureClick
          button={0}
          propagationPhase={Gtk.PropagationPhase.CAPTURE}
          onPressed={(gesture: Gtk.GestureClick, _presses: number, x: number, y: number) => {
            const button = gesture.get_current_button()
            if (button === 1) item.activate(Math.floor(x), Math.floor(y))
            if (button === 2) item.secondary_activate(Math.floor(x), Math.floor(y))
            gesture.set_state(Gtk.EventSequenceState.CLAIMED)
          }}
        />
        {icon}
      </button>
    )
  }

  let menuButton: Gtk.MenuButton
  return (
    <menubutton
      $={(self: Gtk.MenuButton) => {
        menuButton = self
        setPointerCursor(self)
        self.insert_action_group("dbusmenu", item.action_group)
      }}
      class="tray-item"
      tooltipMarkup={tooltip}
      menuModel={item.menu_model}
      onActivate={() => item.about_to_show()}
    >
      <Gtk.GestureClick
        button={0}
        propagationPhase={Gtk.PropagationPhase.CAPTURE}
        onPressed={(gesture: Gtk.GestureClick, _presses: number, x: number, y: number) => {
          const button = gesture.get_current_button()
          const modifiers = gesture.get_current_event_state()
          const modifierMask =
            Gdk.ModifierType.SHIFT_MASK |
            Gdk.ModifierType.CONTROL_MASK |
            Gdk.ModifierType.ALT_MASK |
            Gdk.ModifierType.SUPER_MASK |
            Gdk.ModifierType.META_MASK

          if (button === 3 || (button === 1 && Boolean(modifiers & modifierMask))) {
            item.about_to_show()
            menuButton.popup()
          } else if (button === 2) {
            item.secondary_activate(Math.floor(x), Math.floor(y))
          } else if (button === 1 && !item.is_menu) {
            item.activate(Math.floor(x), Math.floor(y))
          } else {
            return
          }

          gesture.set_state(Gtk.EventSequenceState.CLAIMED)
        }}
      />
      {icon}
    </menubutton>
  )
}

export default function Tray() {
  return (
    <box class="tray" spacing={10}>
      <For each={trayItems}>{(item) => <TrayItem item={item} />}</For>
    </box>
  )
}
