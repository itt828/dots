import QtQuick
import Quickshell
import Quickshell.Io
import "../Widgets"
import "../Common"

Item {
    width: display.width
    height: display.height
    implicitWidth: display.implicitWidth
    implicitHeight: display.implicitHeight

    property string connectionName: "Disconnected"
    property int signalStrength: 0
    property bool isWifi: false
    property bool isConnected: false
    property bool isWifiEnabled: true

    // Monitor for connection changes (instant updates)
    Process {
        id: monitorProc
        command: ["nmcli", "monitor"]
        running: true
        stdout: SplitParser {
            onRead: function(line) {
                // When monitor detects a change, trigger a poll immediately
                pollProc.running = true
            }
        }
    }

    // Poll for details (Signal strength, SSID)
    Process {
        id: pollProc
        command: ["sh", "-c", 
            "RADIO=$(nmcli radio wifi); " +
            "TYPE=$(nmcli -t -f TYPE,STATE,CONNECTION device | grep ':connected:' | head -n 1); " +
            "if echo \"$TYPE\" | grep -q 'ethernet'; then " +
            "  echo \"$RADIO:ETH:100:$(echo \"$TYPE\" | cut -d: -f3)\"; " +
            "elif echo \"$TYPE\" | grep -q 'wifi'; then " +
            "  SIGNAL=$(nmcli -t -f IN-USE,SIGNAL dev wifi | grep '^\\*' | cut -d: -f2); " +
            "  SSID=$(echo \"$TYPE\" | cut -d: -f3); " +
            "  echo \"$RADIO:WIFI:$SIGNAL:$SSID\"; " +
            "else " +
            "  echo \"$RADIO:OFF:0:\"; " +
            "fi"
        ]
        
        stdout: StdioCollector {
            onStreamFinished: {
                if (text) {
                    var line = text.trim()
                    var parts = line.split(":")
                    if (parts.length >= 2) {
                        isWifiEnabled = (parts[0] === "enabled")
                        var type = parts[1]
                        var signal = parseInt(parts[2])
                        var name = parts.slice(3).join(":")
                        
                        if (type === "ETH") {
                            isConnected = true
                            isWifi = false
                            signalStrength = 100
                            connectionName = name
                        } else if (type === "WIFI") {
                            isConnected = true
                            isWifi = true
                            signalStrength = isNaN(signal) ? 0 : signal
                            connectionName = name
                        } else {
                            isConnected = false
                            signalStrength = 0
                            connectionName = "Disconnected"
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 10000 // Poll signal strength every 10s (slower since we have monitor)
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: pollProc.running = true
    }

    BarValue {
        id: display
        value: signalStrength / 100.0
        showLabel: true
        labelText: {
            if (!isWifiEnabled) return "Disabled"
            return isConnected ? connectionName : "Off"
        }

        iconName: {
            if (!isWifiEnabled) return FontIcons.power
            if (!isConnected) return FontIcons.wifiX
            if (!isWifi) return FontIcons.wifiHigh // Ethernet
            
            if (signalStrength > 80) return FontIcons.wifiHigh
            if (signalStrength > 50) return FontIcons.wifiMedium
            if (signalStrength > 20) return FontIcons.wifiLow
            return FontIcons.wifiNone
        }

        progressColor: isConnected ? "black" : "#555555"
        trackColor: "#aaaaaa"
    }
}
