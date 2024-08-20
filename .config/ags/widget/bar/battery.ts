const batteryService = await Service.import("battery")

export const battery = ()=> Widget.Label({
  label: batteryService.bind("percent").as(v=> `${v}%`)

})
