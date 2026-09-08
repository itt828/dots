import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    required property var volumeService
    spacing: 12

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: outputLayout.implicitHeight + 24
        radius: 8
        color: "#ffffff"

        ColumnLayout {
            id: outputLayout
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Text { text: "Output"; font.bold: true; color: "#37474f" }
                Text { text: root.volumeService.sinkName; color: "#607d8b"; elide: Text.ElideRight; Layout.fillWidth: true }
                Button { text: root.volumeService.muted ? "Unmute" : "Mute"; onClicked: root.volumeService.toggleMute() }
            }
            RowLayout {
                Layout.fillWidth: true
                Slider {
                    Layout.fillWidth: true
                    from: 0; to: 1
                    value: root.volumeService.volume
                    onMoved: root.volumeService.setVolume(value)
                }
                Text { text: Math.round(root.volumeService.volume * 100) + "%"; color: "#37474f"; Layout.preferredWidth: 44 }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: inputLayout.implicitHeight + 24
        radius: 8
        color: "#ffffff"

        ColumnLayout {
            id: inputLayout
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Text { text: "Input"; font.bold: true; color: "#37474f" }
                Text { text: root.volumeService.sourceName; color: "#607d8b"; elide: Text.ElideRight; Layout.fillWidth: true }
                Button { text: root.volumeService.sourceMuted ? "Unmute" : "Mute"; onClicked: root.volumeService.toggleSourceMute() }
            }
            RowLayout {
                Layout.fillWidth: true
                Slider {
                    Layout.fillWidth: true
                    from: 0; to: 1
                    value: root.volumeService.sourceVolume
                    onMoved: root.volumeService.setSourceVolume(value)
                }
                Text { text: Math.round(root.volumeService.sourceVolume * 100) + "%"; color: "#37474f"; Layout.preferredWidth: 44 }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 52
        radius: 8
        color: "#ffffff"
        visible: root.volumeService.alsaCardName !== ""

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            Text { text: "Audio profile"; font.bold: true; color: "#37474f" }
            Item { Layout.fillWidth: true }
            Text { text: root.volumeService.isHeadphones ? "Headphones" : "Speaker"; color: "#607d8b" }
            Button { text: "Switch"; onClicked: root.volumeService.toggleProfile() }
        }
    }
}
