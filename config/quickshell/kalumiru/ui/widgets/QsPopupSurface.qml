import QtQuick
import qs.ui.theme

Rectangle {
    id: root

    property bool shown: true
    property bool animated: true
    property bool ready: false
    property real entryX: 12
    property real entryY: -12
    property real closedScale: 0.95
    property real reveal: 0
    readonly property real progress: Math.max(0, Math.min(1, reveal))
    readonly property real offsetX: (1 - reveal) * entryX
    readonly property real offsetY: (1 - reveal) * entryY
    readonly property bool blurActive: reveal > 0

    visible: shown || reveal > 0
    enabled: shown
    opacity: progress
    scale: closedScale + (1 - closedScale) * reveal
    transformOrigin: Item.TopRight
    transform: Translate {
        x: root.offsetX
        y: root.offsetY
    }

    Behavior on color {
        QsColorAnimation {}
    }
    Behavior on border.color {
        QsColorAnimation {}
    }

    function updateReveal(): void {
        if (!ready)
            return;
        const end = shown ? 1 : 0;
        motion.stop();
        if (!animated || !Theme.motionEnabled || reveal === end) {
            reveal = end;
            return;
        }

        motion.from = reveal;
        motion.to = end;
        motion.duration = shown ? Theme.motionEnter : Theme.motionExit;
        motion.easing.type = shown ? Easing.OutBack : Easing.InCubic;
        motion.start();
    }

    Component.onCompleted: {
        ready = true;
        updateReveal();
    }

    Connections {
        target: root
        function onShownChanged(): void {
            root.updateReveal();
        }
    }

    Connections {
        target: Theme
        function onMotionEnabledChanged(): void {
            if (!Theme.motionEnabled)
                root.updateReveal();
        }
    }

    QsNumberAnimation {
        id: motion
        target: root
        property: "reveal"
        easing.overshoot: 0.55
    }
}
