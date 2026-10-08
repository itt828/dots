import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Theme

ColumnLayout {
    id: root
    required property var volumeService
    spacing: 12

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: outputLayout.implicitHeight + 24
        radius: 12
        color: Theme.surface
        border.color: Theme.outline
        border.width: 1

        ColumnLayout {
            id: outputLayout
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Text {
            font.family: Theme.fontFamily
            text: "Output"; font.bold: true; color: Theme.text }
                Text {
            font.family: Theme.fontFamily
            text: root.volumeService.sinkName; color: Theme.textSecondary; elide: Text.ElideRight; Layout.fillWidth: true }
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
                Text {
            font.family: Theme.fontFamily
            text: Math.round(root.volumeService.volume * 100) + "%"; color: Theme.text; Layout.preferredWidth: 44 }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: inputLayout.implicitHeight + 24
        radius: 12
        color: Theme.surface
        border.color: Theme.outline
        border.width: 1

        ColumnLayout {
            id: inputLayout
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Text {
            font.family: Theme.fontFamily
            text: "Input"; font.bold: true; color: Theme.text }
                Text {
            font.family: Theme.fontFamily
            text: root.volumeService.sourceName; color: Theme.textSecondary; elide: Text.ElideRight; Layout.fillWidth: true }
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
                Text {
            font.family: Theme.fontFamily
            text: Math.round(root.volumeService.sourceVolume * 100) + "%"; color: Theme.text; Layout.preferredWidth: 44 }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 52
        radius: 12
        color: Theme.surface
        border.color: Theme.outline
        border.width: 1
        visible: root.volumeService.alsaCardName !== ""

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            Text {
            font.family: Theme.fontFamily
            text: "Audio profile"; font.bold: true; color: Theme.text }
            Item { Layout.fillWidth: true }
            Text {
            font.family: Theme.fontFamily
            text: root.volumeService.isHeadphones ? "Headphones" : "Speaker"; color: Theme.textSecondary }
            Button { text: "Switch"; onClicked: root.volumeService.toggleProfile() }
        }
    }
}
