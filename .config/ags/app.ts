import GLib from "gi://GLib"

GLib.setenv("FONTCONFIG_FILE", `${SRC}/fontconfig.xml`, true)

const { default: app } = await import("ags/gtk4/app")
const { exec } = await import("ags/process")
const { config } = await import("./modules/common/config")
const { default: Dashboard } = await import("./modules/common/dashboard/Dashboard")
const { default: PowerMenu } = await import("./modules/common/power/PowerMenu")
const { default: SearchWindow } = await import("./modules/common/search/SearchWindow")
const { toggleWindow } = await import("./modules/common/windows")
const { default: Bar } = await import("./modules/bar/Bar")

const uno = exec([
  `${SRC}/node_modules/.bin/unocss`,
  `${SRC}/**/*.tsx`,
  "--config",
  `${SRC}/uno.config.ts`,
  "--stdout",
])

app.start({
  instanceName: "ags",
  css: uno,
  main() {
    const monitors = app.get_monitors().filter((monitor) => {
      const connector = monitor.get_connector() ?? ""
      return config.targetScreens.length === 0 || config.targetScreens.includes(connector)
    })
    monitors.forEach(Bar)
    const controlMonitor = monitors[0] ?? app.get_monitors()[0]
    if (controlMonitor) {
      SearchWindow(controlMonitor)
      Dashboard(controlMonitor)
      PowerMenu(controlMonitor)
    }
  },
  requestHandler(argv, response) {
    const command = argv[0]
    if (["dashboard", "power-menu"].includes(command)) {
      toggleWindow(command)
      response(`${command}: ${app.get_window(command)?.visible ? "visible" : "hidden"}`)
    } else if (command === "status") {
      response(app.windows.map((window) => `${window.name}=${window.visible}`).join("\n"))
    } else {
      response("usage: ags request -i ags dashboard|power-menu|status")
    }
  },
})
