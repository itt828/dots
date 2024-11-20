const screen = Utils.exec("sh -c 'ls -w1 /sys/class/backlight | head -1'")

class Brightness extends Service {
  static {
    Service.register(this, {}, {
      "screen": ["float", "rw"]
    })
  }
  #screenMax = Number(Utils.exec('brightnessctl max'))
  #screen = Number(Utils.exec('brightnessctl get')) / Number(Utils.exec('brightnessctl max'))

  get screen() { return this.#screen }
  set screen(value: number) {
    Utils.execAsync(`brightnessctl set ${value * 100}% -q`).then(() => {
      this.#screen = value
      this.changed("screen")
    })
  }
  constructor() {
    super()
    const screenPath = `/sys/class/backlight/${screen}/brightness`
    Utils.monitorFile(screenPath, async f => {
      Utils.readFileAsync(f).then(v => {
        this.#screen = Number(v) / this.#screenMax
        this.changed("screen")

      })

    })
  }
}

export default new Brightness
