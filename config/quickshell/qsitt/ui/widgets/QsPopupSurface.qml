import QtQuick
import qs.ui.theme

Rectangle {
    id: root

    property bool shown: true
    property bool animated: true
    property bool ready: false
    property real reveal: shown && ready ? 1 : 0
    readonly property bool blurActive: shown && reveal > 0

    visible: shown || reveal > 0
    enabled: shown
    opacity: reveal
    scale: 0.97 + reveal * 0.03
    transformOrigin: Item.TopRight
    Behavior on color {
        QsColorAnimation {}
    }
    Behavior on border.color {
        QsColorAnimation {}
    }

    Component.onCompleted: ready = true

    Behavior on reveal {
        enabled: root.animated
        QsNumberAnimation {
            duration: root.shown ? Theme.motionEnter : Theme.motionExit
        }
    }
}
