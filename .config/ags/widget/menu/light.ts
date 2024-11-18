import brightness from "service/brightness"


const LightSlider = () => Widget.Slider({
  min: 0.01,
  max: 100,
  on_change: async ({ value }) => {
    brightness.screen = value / 100
  },
  setup: self => self.hook(brightness, (self) => {
    self.value = brightness.screen * 100
  })
})

const MinimizeButton = () => Widget.Button({
  on_primary_click: () => brightness.screen = 0
})

export const Light = () => Widget.Box({
  vertical: false,
  children: [
    LightSlider(),
    MinimizeButton(),
  ]
})
