import QtQuick
import Quickshell.Io
import "UI"

Item {
    id: root
    width: display.width
    height: display.height
    implicitWidth: display.implicitWidth
    implicitHeight: display.implicitHeight

    property real memVal: 0.0
    property string memText: "-"

    // Memory Widget
    BarValue {
        id: display
        value: root.memVal
        iconName: FontIcons.ram
        showLabel: true
        labelText: root.memText
        progressColor: "black"
        trackColor: "#aaaaaa"
    }

    // Memory Usage
    Process {
        id: memProc
        // (Total - Available) / Total
        command: ["sh", "-c", "free | grep Mem | awk '{print ($2-$7)/$2}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text) {
                    var val = parseFloat(text)
                    if (!isNaN(val)) {
                        root.memVal = val
                        root.memText = (val * 100).toFixed(0) + "%"
                    }
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            memProc.running = true
        }
    }
}
