import QtQuick
import QtQuick.Effects
import qs.ui.theme

RectangularShadow {
    id: root

    required property Rectangle surface
    readonly property QsPopupSurface popup: surface as QsPopupSurface

    anchors.fill: surface
    radius: surface.radius
    visible: surface.visible
    opacity: surface.opacity
    scale: surface.scale
    transformOrigin: surface.transformOrigin
    transform: Translate {
        x: root.popup?.offsetX ?? 0
        y: root.popup?.offsetY ?? 0
    }
    z: surface.z
    color: Theme.shadow
    blur: Theme.windowShadowBlur
    offset: Qt.vector2d(0, Theme.windowShadowOffset)
}
