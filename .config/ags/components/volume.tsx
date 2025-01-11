import { bind } from "astal"
import AstalWp from "gi://AstalWp"

export const Volume = () => {
  const audio = AstalWp.get_default()?.audio
  const speaker = audio?.get_default_speaker()

  return <box className="Volume"
    spacing={8}
  >
    {
      speaker ?
        <>
          <icon icon={bind(speaker, "volume_icon")} />
          <label label={bind(speaker, "volume").as(p => `${Math.floor(p * 100)}%`)} />
        </>
        : <></>

    }
  </box>
}
