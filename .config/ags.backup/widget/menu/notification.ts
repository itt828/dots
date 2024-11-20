const notificationsService = await Service.import("notifications")
export const notifications = () => Widget.Box({
  children: [
    Widget.Label({
      label: notificationsService.bind("notifications").as(n => String(n.length))
    })
  ]
})
