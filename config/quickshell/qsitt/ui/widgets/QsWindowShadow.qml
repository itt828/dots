import QtQuick
import QtQuick.Effects
import qs.ui.theme

// Place before the surface, as a sibling, so its clipping does not cut off the shadow.
RectangularShadow {
    required property Rectangle surface

    anchors.fill: surface
    radius: surface.radius
    visible: surface.visible
    opacity: surface.opacity
    scale: surface.scale
    transformOrigin: surface.transformOrigin
    z: surface.z
    color: Theme.windowShadowColor
    blur: Theme.windowShadowBlur
    offset: Qt.vector2d(0, Theme.windowShadowOffset)
}
