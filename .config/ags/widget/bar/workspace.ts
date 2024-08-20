const hyprland = await Service.import("hyprland")

const activeWsId = hyprland.active.workspace.bind("id").as(v => v.toString())


const isActive = (ws: number) => hyprland.active.workspace.id === ws
const isOccupied = (ws: number) =>
  (hyprland.getWorkspace(ws)?.windows || 0) > 0

const wsLabel = (ws: number) => Widget.Label({
  label: String(ws),
  setup: self => self.hook(hyprland, () => {
    self.toggleClassName("active", isActive(ws))
    self.toggleClassName("occupied", isOccupied(ws))
  })
})

export const workspace = (maxWSNum: number) => Widget.Box({
  spacing: 12,
  children: (new Array(maxWSNum).fill(1).map((_, i) => wsLabel(i + 1)))
})
