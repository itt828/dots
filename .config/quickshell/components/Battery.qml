import QtQuick
import Quickshell.Services.UPower
import "UI"

Row {
    id: root
    spacing: 10

    Repeater {
        model: UPower.devices

        delegate: Item {
            visible: modelData.type === UPowerDeviceType.Battery && modelData.isPresent
            width: display.width
            height: display.height

            BarValue {
                id: display
                value: modelData.percentage
                iconName: {
                    if (modelData.state === UPowerDeviceState.Charging) return FontIcons.batteryCharging
                    if (modelData.percentage > 0.9) return FontIcons.batteryFull
                    if (modelData.percentage > 0.7) return FontIcons.batteryHigh
                    if (modelData.percentage > 0.3) return FontIcons.batteryMedium
                    return FontIcons.batteryLow
                }
                showLabel: true
                labelText: Math.round(modelData.percentage * 100) + "%"

                progressColor: modelData.state === UPowerDeviceState.Charging ? "#00AA00" : (modelData.percentage < 0.2 ? "red" : "black")
                trackColor: "#aaaaaa"
            }
        }
    }
}
