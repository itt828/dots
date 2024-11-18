const cpuVariable = Variable(0, {
  poll: [2000, 'top -b -n 1', out => [100, out.split("\n").find(line => line.includes("Cpu(s)")).split(/s+/)[1].replace(",", ".")]]
})

export const cpu = () => Widget.Box({
  children: [
    Widget.Label({
      label: cpuVariable.bind().as(v => String(v))
    })
  ]
})
