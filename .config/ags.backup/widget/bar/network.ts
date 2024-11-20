const networkService = await Service.import("network")

export const network = () => Widget.Label({
  label: networkService.wifi.bind("ssid").as(v => v ?? "no connection")
})
