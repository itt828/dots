import app from "ags/gtk4/app"

export function toggleWindow(name: string) {
  const window = app.get_window(name)
  if (!window) throw new Error(`window not found: ${name}`)
  if (window.visible) window.hide()
  else window.present()
}
