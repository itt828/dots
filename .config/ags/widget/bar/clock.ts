import GLib from "gi://GLib"
const currentTime = Variable(GLib.DateTime.new_now_local(), {
  poll: [1000, () => GLib.DateTime.new_now_local()]
})

export const clock = () => Widget.Label({
  label: currentTime.bind().as(v=> v.format("%m/%e %a %H:%M:%S")!)
})
