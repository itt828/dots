const audio = await Service.import("audio")
export const volume = () => Widget.Slider({
  min: 0,
  max: 1,
  on_change: ({ value }) => audio.speaker.volume = value,
  setup: self => self.hook(audio.speaker, () => {
    self.value = audio.speaker.volume || 0
  })
})
