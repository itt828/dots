import { Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { createPoll } from "ags/time"

import { run } from "../../../services"
import { pointerCursor } from "../cursor"
import { phosphor } from "../icons"

export default function MediaCard() {
  const media = createPoll("No Media\n-", 2_000, async () => {
    try {
      return await execAsync(["playerctl", "metadata", "--format", "{{title}}\n{{artist}}"])
    } catch {
      return "No Media\n-"
    }
  })

  return (
    <box class="card media" orientation={Gtk.Orientation.VERTICAL} spacing={8}>
      <box spacing={8}>
        <label class="control-icon font-phosphor" label={phosphor.mediaMusic} />
        <label class="section-title" xalign={0} label="Media" />
      </box>
      <label
        class="card-title"
        xalign={0}
        ellipsize={3}
        label={media((value) => value.split("\n")[0] || "No Media")}
      />
      <label
        class="secondary"
        xalign={0}
        ellipsize={3}
        label={media((value) => value.split("\n")[1] || "-")}
      />
      <box halign={Gtk.Align.CENTER} spacing={16}>
        <button
          {...pointerCursor}
          class="action-button icon-button"
          onClicked={() => run(["playerctl", "previous"])}
        >
          <label class="font-phosphor" label={phosphor.mediaPrev} />
        </button>
        <button
          {...pointerCursor}
          class="action-button icon-button"
          onClicked={() => run(["playerctl", "play-pause"])}
        >
          <label class="font-phosphor" label={phosphor.mediaPlay} />
        </button>
        <button
          {...pointerCursor}
          class="action-button icon-button"
          onClicked={() => run(["playerctl", "next"])}
        >
          <label class="font-phosphor" label={phosphor.mediaNext} />
        </button>
      </box>
    </box>
  )
}
