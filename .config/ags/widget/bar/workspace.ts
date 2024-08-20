const hyprland = await Service.import("hyprland")
const activeWsId = hyprland.active.workspace.bind("id").as(v => v.toString())
export const workspace = () => Widget.Label({
  label: activeWsId
})
