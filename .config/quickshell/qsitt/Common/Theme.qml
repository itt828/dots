pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

QtObject {
    readonly property color background: "#eef2f5"
    readonly property color surface: "#ffffff"
    readonly property color surfaceVariant: "#e8eef2"
    readonly property color surfaceContainer: "#f6f8fa"
    readonly property color surfaceContainerHigh: "#e1e8ed"
    readonly property color primary: "#0078d4"
    readonly property color primaryContainer: "#d8ebff"
    readonly property color primaryText: "#ffffff"
    readonly property color text: "#000000"
    readonly property color textSecondary: "#52616b"
    readonly property color outline: "#bcc8cf"
    readonly property color accent: "#0078d4"
    readonly property color danger: "#ff6b6b"
    readonly property color success: "#00aa00"

    readonly property int radius: 8
    readonly property int radiusSmall: 6
    readonly property int radiusLarge: 18
    readonly property int padding: 10
    readonly property int spacing: 10
    readonly property int spacingSmall: 6
    readonly property int spacingLarge: 16

    readonly property int fontSizeSmall: 11
    readonly property int fontSizeBody: 13
    readonly property int fontSizeTitle: 20

    function withAlpha(color: color, alpha: real): color {
        return Qt.rgba(color.r, color.g, color.b, alpha);
    }

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
