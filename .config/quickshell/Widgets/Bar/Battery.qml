import QtQuick
import Quickshell.Services.UPower
import "../../Assets"

Row {
    id: root
    spacing: 10

    Repeater {
        model: UPower.devices

        delegate: Rectangle {
            visible: modelData.type === UPowerDeviceType.Battery && modelData.isPresent

            color: (modelData.percentage < 0.2 && modelData.state !== UPowerDeviceState.Charging) ? Theme.danger : "transparent"
            radius: 4

            implicitWidth: display.implicitWidth + 8
            implicitHeight: display.implicitHeight + 4

            IconLabel {
                id: display
                anchors.centerIn: parent

                icon: {
                    if (modelData.state === UPowerDeviceState.Charging)
                        return FontIcons.batteryCharging;
                    if (modelData.percentage > 0.9)
                        return FontIcons.batteryFull;
                    if (modelData.percentage > 0.7)
                        return FontIcons.batteryHigh;
                    if (modelData.percentage > 0.3)
                        return FontIcons.batteryMedium;
                    return FontIcons.batteryLow;
                }

                text: Math.round(modelData.percentage * 100) + "%"
                color: {
                    if (modelData.state === UPowerDeviceState.Charging)
                        return Theme.success;
                    if (modelData.percentage < 0.2)
                        return "white";
                    return Theme.text;
                }
            }
        }
    }
}
