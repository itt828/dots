import { config } from "../common/config"

export function barButtonClass(classes = "") {
  return `bar-button ${classes} ${config.barDesign === "kawaii" ? "bar-button-kawaii" : ""}`.trim()
}
