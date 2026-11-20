pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import qs.services

QtObject {
    id: root

    readonly property color bgPrimary: ThemeService.current["bg-primary"]
    readonly property color bgSecondary: ThemeService.current["bg-secondary"]
    readonly property color bgTertiary: ThemeService.current["bg-tertiary"]
    readonly property color textPrimary: ThemeService.current["text-primary"]
    readonly property color textSecondary: ThemeService.current["text-secondary"]
    readonly property color borderPrimary: ThemeService.current["border-primary"]
    readonly property color accent: ThemeService.current["accent"]
    readonly property color success: ThemeService.current["success"]
    readonly property color warn: ThemeService.current["warn"]
    readonly property color statusError: ThemeService.current["status/error"]
    readonly property color info: ThemeService.current["info"]
    readonly property color surface: ThemeService.current["surface"]
    readonly property color ink: ThemeService.current["ink"]
    readonly property color muted: ThemeService.current["muted"]
    readonly property color border: ThemeService.current["border"]
    readonly property color subtle: ThemeService.current["subtle"]
    readonly property color hover: ThemeService.current["hover"]
    readonly property color pressed: ThemeService.current["pressed"]
    readonly property color focus: ThemeService.current["focus"]
    readonly property color disabled: ThemeService.current["disabled"]
    readonly property color disabledInk: ThemeService.current["disabled-ink"]
    readonly property color accentHover: ThemeService.current["accent-hover"]
    readonly property color accentPressed: ThemeService.current["accent-pressed"]
    readonly property color error: ThemeService.current["error"]
    readonly property color errorHover: ThemeService.current["error-hover"]
    readonly property color errorPressed: ThemeService.current["error-pressed"]
    readonly property color errorSurface: ThemeService.current["error-surface"]
    readonly property color mustard50: ThemeService.current["mustard/50"]
    readonly property color mustard200: ThemeService.current["mustard/200"]
    readonly property color mustard500: ThemeService.current["mustard/500"]
    readonly property color mustard800: ThemeService.current["mustard/800"]
    readonly property color canvasWarm: ThemeService.current["canvas/warm"]
    readonly property color shadow: ThemeService.current["shadow"]

    readonly property color glassPanel: withAlpha(surface, 0.94)
    readonly property color glassPopup: withAlpha(bgTertiary, 0.94)
    readonly property color glassOutline: withAlpha(borderPrimary, 0.85)
    readonly property color glassScrim: withAlpha(ink, 0.12)
    readonly property int windowShadowBlur: 18
    readonly property int windowShadowOffset: 12
    readonly property int windowShadowPadding: 30
    readonly property int toastSlide: 28

    readonly property real motionScale: Math.max(0, SettingsService.animationDuration) / 200
    readonly property bool motionEnabled: motionScale > 0
    readonly property int motionFast: Math.round(120 * motionScale)
    readonly property int motionNormal: Math.round(205 * motionScale)
    readonly property int motionEnter: Math.round(275 * motionScale)
    readonly property int motionExit: Math.round(175 * motionScale)

    readonly property string fontFamily: Qt.fontFamilies().includes("M PLUS 1") ? "M PLUS 1" : "M+ 1p"
    readonly property int fontSizeSmall: 12
    readonly property int fontSizeBody: 14
    readonly property int fontSizeTitle: 18

    readonly property int radius: 8
    readonly property int radiusSmall: 6
    readonly property int radiusLarge: 20
    readonly property int padding: 10
    readonly property int spacing: 10
    readonly property int spacingSmall: 6
    readonly property int spacingLarge: 16

    function withAlpha(color: color, alpha: real): color {
        return Qt.rgba(color.r, color.g, color.b, alpha);
    }

    readonly property int popupInset: 24
    readonly property int controlWidth: 494
    readonly property int expandedWidth: 1280
    readonly property int barHeight: 46
    readonly property int barRadius: 15
    readonly property int barOuterMargin: 8
    readonly property int belowBar: barHeight + 16
}
