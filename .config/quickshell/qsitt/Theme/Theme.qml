pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

QtObject {
    // Assign another theme object to `current` to replace colors and fonts.
    property QtObject current: DefaultTheme {}

    readonly property color background: current.background
    readonly property color surface: current.surface
    readonly property color surfaceVariant: current.surfaceVariant
    readonly property color surfaceContainer: current.surfaceContainer
    readonly property color surfaceContainerHigh: current.surfaceContainerHigh
    readonly property color primary: current.primary
    readonly property color primaryContainer: current.primaryContainer
    readonly property color primaryText: current.primaryText
    readonly property color text: current.text
    readonly property color textSecondary: current.textSecondary
    readonly property color outline: current.outline
    readonly property color accent: current.accent
    readonly property color danger: current.danger
    readonly property color success: current.success

    readonly property string fontFamily: current.fontFamily
    readonly property int fontSizeSmall: current.fontSizeSmall
    readonly property int fontSizeBody: current.fontSizeBody
    readonly property int fontSizeTitle: current.fontSizeTitle

    readonly property int radius: 8
    readonly property int radiusSmall: 6
    readonly property int radiusLarge: 18
    readonly property int padding: 10
    readonly property int spacing: 10
    readonly property int spacingSmall: 6
    readonly property int spacingLarge: 16

    function withAlpha(color: color, alpha: real): color {
        return Qt.rgba(color.r, color.g, color.b, alpha);
    }

    // Bar design tokens
    readonly property color barBackground: current.barBackground
    readonly property color barBorder: current.barBorder
    readonly property int barBorderWidth: 2
    readonly property int barHeight: 32
    readonly property int barOuterMargin: 8
    readonly property int barHorizontalPadding: 12
    readonly property int barSectionSpacing: 12
    readonly property int barModuleSpacing: 8
}
