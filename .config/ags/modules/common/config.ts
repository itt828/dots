export type BarModule =
  | "search"
  | "workspaces"
  | "windowTitle"
  | "clock"
  | "tray"
  | "notifications"
  | "volume"
  | "microphone"
  | "brightness"
  | "cpu"
  | "memory"
  | "network"
  | "battery"
  | "power"

export const config = {
  // Empty means every monitor, matching qsitt/Assets/Config.qml.
  targetScreens: ["eDP-1"],
  barDesign: "default" as "default" | "minimal" | "kawaii",
  barLayout: {
    left: ["search", "workspaces", "windowTitle"],
    center: ["clock"],
    right: [
      "tray",
      "notifications",
      "volume",
      "microphone",
      "brightness",
      "network",
      "battery",
      "power",
    ],
  } satisfies Record<"left" | "center" | "right", BarModule[]>,
}
