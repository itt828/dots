import { Astal, Gdk, Gtk } from "ags/gtk4"
import app from "ags/gtk4/app"

import { run } from "../../../services"
import { pointerCursor } from "../cursor"
import { phosphor } from "../icons"

const GOOGLE_SEARCH_URL = "https://www.google.com/search?q="

export default function SearchWindow(gdkmonitor: Gdk.Monitor) {
  let entry: Gtk.Entry

  function close() {
    const window = app.get_window("search")
    if (window?.visible) window.hide()
    entry.text = ""
  }

  function search() {
    const query = entry.text.trim()
    if (!query) return
    run(["xdg-open", `${GOOGLE_SEARCH_URL}${encodeURIComponent(query)}`])
    close()
  }

  function searchWithLens() {
    close()
    run([`${SRC}/scripts/google-lens-region.sh`])
  }

  return (
    <window
      name="search"
      class="Search"
      visible={false}
      gdkmonitor={gdkmonitor}
      application={app}
      anchor={Astal.WindowAnchor.TOP}
      layer={Astal.Layer.OVERLAY}
      keymode={Astal.Keymode.EXCLUSIVE}
      exclusivity={Astal.Exclusivity.IGNORE}
      onNotifyVisible={(self) => {
        if (self.visible) entry.grab_focus()
      }}
    >
      <Gtk.EventControllerKey
        onKeyPressed={(_controller, keyval) => {
          if (keyval !== Gdk.KEY_Escape) return false
          close()
          return true
        }}
      />
      <box class="search-shell" spacing={8}>
        <label class="phosphor-icon large-icon" label={phosphor.search} />
        <entry
          $={(self) => (entry = self)}
          class="search-entry"
          hexpand
          placeholderText="Googleで検索"
          onActivate={search}
        />
        <button
          {...pointerCursor}
          class="search-action search-lens"
          tooltipText="範囲を選択してGoogle Lensで検索"
          onClicked={searchWithLens}
        >
          <label label="Lens" />
        </button>
        <button
          {...pointerCursor}
          class="search-action icon-button"
          tooltipText="閉じる"
          onClicked={close}
        >
          <label class="phosphor-icon" label={phosphor.x} />
        </button>
      </box>
    </window>
  )
}
