import { presetGtk } from "@itt/unocss-preset-gtk"
import { defineConfig } from "unocss"

const colors = {
  background: "#eef2f5",
  surface: "#ffffff",
  surfaceVariant: "#dde4e8",
  bar: "#c4d0d6",
  border: "#6f8792",
  text: "#172126",
  secondary: "#60727b",
  accent: "#0078d4",
  danger: "#ff6b6b",
  white: "#ffffff",
  buttonHover: "#c9d7de",
  notificationSurface: "#f7fafb",
  notificationBorder: "#d4dfe4",
  toolBadge: "#e3f2fd",
  powerHover: "#d7e8f2",
  kawaiiBar: "#ffddec",
  kawaiiBorder: "#dc8db2",
  kawaiiHover: "#fff2f8",
  highlight: "rgba(0, 120, 212, 0.4)",
  overlay: "rgba(15, 23, 28, 0.6)",
} as const satisfies Record<string, string>

export default defineConfig({
  presets: [presetGtk()],
  theme: { colors, spacing: {}, fontSize: {} },
  shortcuts: {
    Bar: "bg-transparent text-text text-13 font-semibold font-sans",
    "bar-shell":
      "min-h-8 mt-2 mx-2 mb-0 py-0 px-3 border-2 border-solid border-border rounded-8 bg-bar shadow-none",
    "bar-shell-minimal": "m-0 border-0 rounded-none shadow-none",
    "bar-shell-kawaii": "rounded-18 bg-kawaiiBar border-kawaiiBorder",
    "bar-button":
      "min-h-[22px] py-0 px-[5px] border-0 rounded-6 bg-transparent text-text shadow-none hover:bg-transparent active:bg-transparent",
    "bar-button-kawaii": "hover:bg-transparent",
    Search: "bg-transparent text-text text-13 font-sans",
    "search-shell":
      "min-w-[520px] mt-4 p-2 border-1 border-solid border-border rounded-14 bg-background shadow-none",
    "search-entry": "min-w-[380px] min-h-9 px-3 border-0 rounded-10 bg-surfaceVariant text-text",
    "search-action":
      "min-h-9 px-3 border-0 rounded-10 bg-surfaceVariant text-text shadow-none hover:bg-buttonHover",
    "search-lens": "bg-accent text-white hover:bg-accent",
    module: "px-[3px]",
    "status-module": "rounded-6",
    "phosphor-icon": "min-w-4 text-16 font-medium font-phosphor",
    icon: "min-w-[22px] p-0 text-16",
    "window-title": "min-w-5 ml-[6px]",
    "battery-low": "py-[1px] px-[5px] rounded-5 bg-danger text-white",
    workspace: "min-w-4 min-h-4 p-0 rounded-2 bg-surface border-0",
    "workspace-focused": "bg-accent text-white",
    "workspace-active": "bg-[#505050] text-white",
    "workspace-urgent": "bg-danger text-white",
    Dashboard: "bg-transparent text-text text-13 font-sans",
    "dashboard-shell":
      "min-w-270 mt-14 p-4 border-1 border-solid border-border rounded-18 bg-background shadow-none",
    "profile-card": "p-3 rounded-14 bg-surface",
    "profile-avatar": "min-w-11 min-h-11 rounded-22 bg-accent text-white text-18 font-bold",
    "profile-name": "text-15 font-bold",
    "profile-time": "text-20 font-bold",
    "quick-setting":
      "min-h-14 p-[10px] rounded-14 border-0 bg-surfaceVariant text-text shadow-none hover:bg-buttonHover",
    "quick-setting-active": "bg-accent text-white hover:bg-accent",
    "quick-setting-icon": "min-w-8 text-20",
    "quick-setting-subtitle": "text-11",
    "control-center-card": "p-3 rounded-14 bg-surface",
    "control-center-slider": "min-h-8",
    "system-card": "p-3 rounded-14 bg-surface",
    "dashboard-nav": "p-1 rounded-12 bg-surfaceVariant",
    "dashboard-nav-button":
      "min-h-8 p-1 rounded-9 border-0 bg-transparent text-secondary text-11 shadow-none hover:bg-buttonHover",
    "dashboard-nav-active": "bg-surface text-text font-bold hover:bg-surface",
    "section-title": "text-15 font-bold",
    "card-title": "font-bold",
    secondary: "text-secondary text-12",
    "large-icon": "min-w-9 text-24 text-accent",
    "control-icon": "min-w-7 text-18",
    value: "min-w-[42px]",
    card: "p-3 rounded-10 bg-surface",
    page: "min-h-55 p-3 rounded-10 bg-surface",
    media: "min-h-26",
    "action-button":
      "border-0 rounded-8 bg-surfaceVariant text-text shadow-none hover:bg-buttonHover",
    "icon-button": "min-w-8 min-h-8 p-0 text-18",
    "tab-button": "min-h-[38px] text-18",
    "tool-card":
      "p-3 rounded-10 bg-surfaceVariant text-text border-1 border-solid border-transparent shadow-none hover:bg-buttonHover hover:border-accent",
    "tool-badge": "min-w-10 min-h-10 rounded-8 bg-toolBadge text-accent font-bold",
    "tray-item":
      "min-w-4 min-h-4 p-0 rounded-none bg-transparent hover:bg-transparent active:bg-transparent",
    "notification-history": "min-h-[210px]",
    "notification-card":
      "p-[10px] rounded-8 bg-notificationSurface border-1 border-solid border-notificationBorder",
    "notification-app": "text-secondary text-11",
    "notification-summary": "font-bold",
    "notification-close": "min-w-6 min-h-6 p-0",
    "list-item": "py-[7px] px-[9px]",
    "list-item-active": "bg-accent text-white",
    "timer-value": "text-accent text-18 font-bold",
    PowerMenu: "bg-overlay text-text text-13 font-sans",
    "power-card": "p-6 border-1 border-solid border-border rounded-16 bg-background shadow-none",
    "power-option": "min-w-24 min-h-24 hover:bg-powerHover",
    "power-icon": "text-28 text-accent",
  },
  rules: [
    [/^shadow-none$/, () => ({ "box-shadow": "none" })],
    [/^font-sans$/, () => ({ "font-family": '"Noto Sans", "Symbols Nerd Font", sans-serif' })],
    [/^font-phosphor$/, () => ({ "font-family": '"Phosphor"', "font-weight": 500 })],
    [
      /^module-flash$/,
      () => ({
        "animation-name": "module-flash",
        "animation-duration": "600ms",
        "animation-timing-function": "ease-out",
      }),
    ],
    [/^tracking-\[(.+)\]$/, ([, value = "0"]) => ({ "letter-spacing": value })],
    [
      /^font-(light|normal|medium|semibold|bold)$/,
      ([, weight = "normal"]) => ({
        "font-weight":
          { light: 300, normal: 400, medium: 500, semibold: 600, bold: 700 }[weight] ?? 400,
      }),
    ],
    [/^text-(\d+)$/, ([, size = "0"]) => ({ "font-size": `${size}px` })],
  ],
  preflights: [
    {
      getCSS: () => `
        .Bar,
        .Search,
        .Dashboard,
        .PowerMenu {
          box-shadow: none;
        }

        .Bar button.bar-button,
        .Bar button.bar-button:hover,
        .Bar button.bar-button:active,
        .Bar button.bar-button:focus,
        .Bar menubutton.bar-button,
        .Bar menubutton.bar-button > button,
        .Bar menubutton.bar-button > button:hover,
        .Bar menubutton.bar-button > button:active,
        .Bar menubutton.bar-button > button:focus {
          background: transparent;
          background-image: none;
          border: none;
          box-shadow: none;
        }

        .Bar button.tray-item,
        .Bar button.tray-item:hover,
        .Bar button.tray-item:active,
        .Bar button.tray-item:focus,
        .Bar menubutton.tray-item,
        .Bar menubutton.tray-item > button,
        .Bar menubutton.tray-item > button:hover,
        .Bar menubutton.tray-item > button:active,
        .Bar menubutton.tray-item > button:focus {
          background: transparent;
          background-image: none;
          border: none;
          border-radius: 0;
          box-shadow: none;
          padding: 0;
        }

        scrolledwindow undershoot, scrolledwindow overshoot {
          background: none;
          box-shadow: none;
        }

        @keyframes module-flash {
          from { background-color: transparent; }
          16.667% { background-color: rgba(0, 120, 212, 0.4); }
          to { background-color: transparent; }
        }
      `,
    },
  ],
})
