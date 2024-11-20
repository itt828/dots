const memVariable = Variable(0, {
  poll: [2000, 'free', out => out.split('\n')
    .find(line => line.includes('Mem:'))
    .split(/\s+/)
    .splice(1, 2)
  ]
})

export const mem = () => Widget.Box({

  children: [
    Widget.Label({
      label: memVariable.bind().as(v => String(v))
    })
  ]
})
