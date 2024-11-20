const bluetoothService = await Service.import("bluetooth")

export const bluetooth = () => Widget.Box({
  setup: self => self.hook(bluetoothService, self => {
    self.children = bluetoothService.connected_devices.map(({ icon_name, name }) => Widget.Box([
      Widget.Icon(icon_name + '-symbolic'),
      Widget.Label(name)
    ]))
  }, 'notify::connected-devices')
})
