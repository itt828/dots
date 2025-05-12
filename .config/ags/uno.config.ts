import { defineConfig } from "unocss"
import { presetGtk } from "./preset-gtk"

export default defineConfig({
    presets: [
        presetGtk()
    ],
    shortcuts: {
        "bx": "bg-[#f9f2f2aa] rounded-3 mx-2 mt-2 py-1 px-4"
    },
    preflights: [
        {
            getCSS: () => `
            * {
                color: #555555;
                font-family: "M PLUS 1";
                font-weight: 500;
            }
            `
        }
    ]
})