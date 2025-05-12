import { defineConfig } from "unocss"
import { presetGtk } from "./preset-gtk"

export default defineConfig({
    presets: [
        presetGtk()
    ]
})