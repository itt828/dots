import QtQuick
import Quickshell
import Quickshell.Io
import "UI"

Item {
    id: root
    width: display.width
    height: display.height
    implicitWidth: display.implicitWidth
    implicitHeight: display.implicitHeight

    property real brightnessVal: 0.0

    function updateBrightness() {
        var currentStr = ""
        var maxStr = ""

        if (typeof currentBrightness.text === 'string') {
            currentStr = currentBrightness.text
        } else if (typeof currentBrightness.text === 'function') {
            currentStr = currentBrightness.text()
        }

        if (typeof maxBrightness.text === 'string') {
            maxStr = maxBrightness.text
        } else if (typeof maxBrightness.text === 'function') {
            maxStr = maxBrightness.text()
        }

        var current = parseInt(currentStr)
        var max = parseInt(maxStr)
        
        if (!isNaN(current) && !isNaN(max) && max !== 0) {
            root.brightnessVal = current / max
        }
    }

    FileView {
        id: currentBrightness
        path: "/sys/class/backlight/intel_backlight/brightness"
        onLoaded: root.updateBrightness()
    }

    FileView {
        id: maxBrightness
        path: "/sys/class/backlight/intel_backlight/max_brightness"
        onLoaded: root.updateBrightness()
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (typeof currentBrightness.reload === 'function') {
                currentBrightness.reload()
            }
        }
    }

    BarValue {
        id: display
        value: root.brightnessVal
        showLabel: true
        labelText: Math.round(root.brightnessVal * 100) + "%"

        iconName: FontIcons.sunDim

        progressColor: "black"
        trackColor: "#aaaaaa"
    }
}
