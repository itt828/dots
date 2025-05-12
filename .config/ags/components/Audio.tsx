import { bind, Binding, Variable } from "astal"
import AstalWp from "gi://AstalWp"

export const Audio = () => {
    const audio = AstalWp.get_default()?.audio
    const mic = audio?.get_default_microphone()
    const speaker = audio?.get_default_speaker()


    const tooltip = (mi: Binding<string>, sp: Binding<string>): Binding<string> => {
        return mi.as(v => "mic: " + v + "\nspeaker: " + sp.get())
    }

    return <box cssClasses={["Volume"]} spacing={12} tooltipText={tooltip(bind(mic!, "description"), bind(speaker!, "description"))}>
        {speaker ? <Speaker speaker={speaker} /> : <></>}
        {mic ? <Mic mic={mic} /> : <></>}
    </box >
}

const muteIcon = (isMute: boolean) => isMute ? "audio-input-microphone-muted-symbolic" : "audio-input-microphone-symbolic"
const Mic = ({ mic }: { mic: AstalWp.Endpoint }) => <image iconName={bind(mic, "mute").as(muteIcon)} />

const Speaker = ({ speaker }: { speaker: AstalWp.Endpoint }) => <box spacing={8}>
    <image iconName={bind(speaker, "volume_icon")} />
    <label label={bind(speaker, "volume").as(p => `${Math.round(p * 100)}%`)} />
</box>

