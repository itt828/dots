pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import qs.services

QtObject {
    id: root

    readonly property color background: ThemeService.current.background
    readonly property color surface: ThemeService.current.surface
    readonly property color surfaceVariant: ThemeService.current.surfaceVariant
    readonly property color surfaceContainerLow: ThemeService.current.surfaceContainerLow
    readonly property color surfaceContainer: ThemeService.current.surfaceContainer
    readonly property color surfaceContainerHigh: ThemeService.current.surfaceContainerHigh
    readonly property color primary: ThemeService.current.primary
    readonly property color primaryContainer: ThemeService.current.primaryContainer
    readonly property color primaryText: ThemeService.current.primaryText
    readonly property color text: ThemeService.current.text
    readonly property color textSecondary: ThemeService.current.textSecondary
    readonly property color outline: ThemeService.current.outline
    readonly property color outlineVariant: ThemeService.current.outlineVariant
    readonly property color accent: ThemeService.current.accent
    readonly property color danger: ThemeService.current.danger
    readonly property color success: ThemeService.current.success

    readonly property string fontFamily: "sans-serif"
    readonly property int fontSizeSmall: 11
    readonly property int fontSizeBody: 13
    readonly property int fontSizeTitle: 20

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

    readonly property int barBorderWidth: 2
    readonly property int barHeight: 32
    readonly property int barOuterMargin: 8
    readonly property int barHorizontalPadding: 12
    readonly property int barSectionSpacing: 12
    readonly property int barModuleSpacing: 8
}
