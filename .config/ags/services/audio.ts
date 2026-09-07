import AstalWp from "gi://AstalWp"
import { createBinding, createComputed, type Accessor } from "gnim"

export type AudioState = { volume: number; muted: boolean }

const wireplumber = AstalWp.get_default()
const defaultSpeaker = createBinding(wireplumber, "defaultSpeaker")
const defaultMicrophone = createBinding(wireplumber, "defaultMicrophone")
const speakerVolume = createBinding(wireplumber, "defaultSpeaker", "volume")
const speakerMuted = createBinding(wireplumber, "defaultSpeaker", "mute")
const microphoneVolume = createBinding(wireplumber, "defaultMicrophone", "volume")
const microphoneMuted = createBinding(wireplumber, "defaultMicrophone", "mute")

function audioState(volume: Accessor<unknown>, muted: Accessor<unknown>) {
  return createComputed<AudioState>(() => ({
    volume: Math.max(0, Math.min(1, Number(volume() ?? 0))),
    muted: Boolean(muted() ?? true),
  }))
}

export const volume = audioState(speakerVolume, speakerMuted)
export const microphone = audioState(microphoneVolume, microphoneMuted)

function clampVolume(value: number) {
  return Math.max(0, Math.min(1, value))
}

export function setVolume(value: number) {
  const speaker = defaultSpeaker()
  if (speaker) speaker.volume = clampVolume(value)
}

export function setMicrophoneVolume(value: number) {
  const microphone = defaultMicrophone()
  if (microphone) microphone.volume = clampVolume(value)
}

export function toggleVolumeMute() {
  const speaker = defaultSpeaker()
  if (speaker) speaker.mute = !speaker.mute
}

export function toggleMicrophoneMute() {
  const microphone = defaultMicrophone()
  if (microphone) microphone.mute = !microphone.mute
}
