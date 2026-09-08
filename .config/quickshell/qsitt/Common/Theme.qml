pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

QtObject {
    readonly property color background: "#eef2f5"
    readonly property color surface: "#ffffff"
    readonly property color surfaceVariant: "#dddddd"
    readonly property color primary: "#0078d4"
    readonly property color text: "#000000"
    readonly property color textSecondary: "#555555"
    readonly property color accent: "#0078d4"
    readonly property color danger: "#ff6b6b"
    readonly property color success: "#00aa00"

    readonly property int radius: 8
    readonly property int padding: 10
    readonly property int spacing: 10

    // Bar design tokens
    readonly property color barBackground: "#c4d0d6"
    readonly property color barBorder: "#6f8792"
    readonly property int barBorderWidth: 2
    readonly property int barHeight: 32
    readonly property int barOuterMargin: 8
    readonly property int barHorizontalPadding: 12
    readonly property int barSectionSpacing: 12
    readonly property int barModuleSpacing: 8
}
