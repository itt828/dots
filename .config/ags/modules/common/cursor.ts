import { Gtk } from "ags/gtk4"

export function setPointerCursor(widget: Gtk.Widget) {
  widget.set_cursor_from_name("pointer")
}

export const pointerCursor = { $: setPointerCursor }
