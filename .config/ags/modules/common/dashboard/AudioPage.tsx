import { Gtk } from "ags/gtk4"
import { type Accessor } from "gnim"

import {
  services,
  setMicrophoneVolume,
  setVolume,
  toggleMicrophoneMute,
  toggleVolumeMute,
} from "../../../services"
import { pointerCursor } from "../cursor"
import { phosphor } from "../icons"

function SliderRow({
  icon,
  value,
  onChange,
}: {
  icon: string
  value: Accessor<number>
  onChange: (value: number) => void
}) {
  return (
    <box class="control-row" spacing={10}>
      <label class="control-icon font-phosphor" label={icon} />
      <slider hexpand value={value} onValueChanged={(slider: any) => onChange(slider.value)} />
      <label class="value" label={value((current) => `${Math.round(current * 100)}%`)} />
    </box>
  )
}

export default function AudioPage() {
  return (
    <box class="page" orientation={Gtk.Orientation.VERTICAL} spacing={12}>
      <label class="section-title" xalign={0} label="Audio" />
      <SliderRow
        icon={phosphor.volumeHigh}
        value={services.volume((value) => value.volume)}
        onChange={setVolume}
      />
      <SliderRow
        icon={phosphor.microphone}
        value={services.microphone((value) => value.volume)}
        onChange={setMicrophoneVolume}
      />
      <box homogeneous spacing={8}>
        <button {...pointerCursor} class="action-button" onClicked={toggleVolumeMute}>
          <label label="出力をミュート" />
        </button>
        <button {...pointerCursor} class="action-button" onClicked={toggleMicrophoneMute}>
          <label label="マイクをミュート" />
        </button>
      </box>
    </box>
  )
}
