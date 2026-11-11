pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.modules.common.theme
import qs.modules.common.widgets
import qs.services

Scope {
    id: root

    property bool active: false
    property string title: ""
    property string detail: ""
    property string icon: ""
    property real value: 0
    property bool showLevel: true

    property var previousSink: null
    property var previousSource: null
    property real previousVolume: NaN
    property real previousSourceVolume: NaN
    property bool previousMuted: true
    property bool previousSourceMuted: true
    property double sinkChangedAt: 0
    property double sourceChangedAt: 0

    Component.onCompleted: {
        previousSink = VolumeService.sink;
        previousSource = VolumeService.source;
        previousVolume = VolumeService.volume;
        previousSourceVolume = VolumeService.sourceVolume;
        previousMuted = VolumeService.muted;
        previousSourceMuted = VolumeService.sourceMuted;
        sinkChangedAt = Date.now();
        sourceChangedAt = Date.now();
    }

    function show(title, detail, icon, value, showLevel) {
        root.title = title;
        root.detail = detail;
        root.icon = icon;
        root.value = value;
        root.showLevel = showLevel;
        root.active = true;
        hideTimer.restart();
    }

    function outputIcon() {
        if (VolumeService.muted)
            return Icons.volumeMuted;
        if (VolumeService.volume > 0.45)
            return Icons.volumeHigh;
        if (VolumeService.volume > 0)
            return Icons.volumeMedium;
        return Icons.volumeLow;
    }

    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: root.active = false
    }

    Connections {
        target: VolumeService

        function onSinkChanged() {
            const oldSink = root.previousSink;
            root.sinkChangedAt = Date.now();
            if (VolumeService.sink) {
                root.previousSink = VolumeService.sink;
            }
            if (oldSink && VolumeService.sink && oldSink !== VolumeService.sink)
                root.show("出力デバイス", VolumeService.sinkName, root.outputIcon(), VolumeService.volume, false);
        }

        function onSourceChanged() {
            const oldSource = root.previousSource;
            root.sourceChangedAt = Date.now();
            if (VolumeService.source) {
                root.previousSource = VolumeService.source;
            }
            if (oldSource && VolumeService.source && oldSource !== VolumeService.source)
                root.show("入力デバイス", VolumeService.sourceName, Icons.microphone, VolumeService.sourceVolume, false);
        }

        function onVolumeChanged() {
            const oldVolume = root.previousVolume;
            root.previousVolume = VolumeService.volume;
            if (!isNaN(oldVolume) && VolumeService.sink && Date.now() - root.sinkChangedAt > 500)
                root.show("音量", VolumeService.sinkName, root.outputIcon(), VolumeService.volume, true);
        }

        function onMutedChanged() {
            const oldMuted = root.previousMuted;
            root.previousMuted = VolumeService.muted;
            if (VolumeService.sink && oldMuted !== VolumeService.muted && Date.now() - root.sinkChangedAt > 500)
                root.show(VolumeService.muted ? "ミュート" : "音量", VolumeService.sinkName, root.outputIcon(), VolumeService.volume, true);
        }

        function onSourceVolumeChanged() {
            const oldVolume = root.previousSourceVolume;
            root.previousSourceVolume = VolumeService.sourceVolume;
            if (!isNaN(oldVolume) && VolumeService.source && Date.now() - root.sourceChangedAt > 500)
                root.show("マイク音量", VolumeService.sourceName, VolumeService.sourceMuted ? Icons.microphoneSlash : Icons.microphone, VolumeService.sourceVolume, true);
        }

        function onSourceMutedChanged() {
            const oldMuted = root.previousSourceMuted;
            root.previousSourceMuted = VolumeService.sourceMuted;
            if (VolumeService.source && oldMuted !== VolumeService.sourceMuted && Date.now() - root.sourceChangedAt > 500)
                root.show(VolumeService.sourceMuted ? "マイクミュート" : "マイク音量", VolumeService.sourceName, VolumeService.sourceMuted ? Icons.microphoneSlash : Icons.microphone, VolumeService.sourceVolume, true);
        }
    }

    Connections {
        target: BrightnessService

        function onBrightnessChanged() {
            if (BrightnessService.initialized)
                root.show("明るさ", "", Icons.sunDim, BrightnessService.brightness, true);
        }
    }

    Variants {
        model: Quickshell.screens.filter(screen => SettingsService.targetScreens.length === 0 || SettingsService.targetScreens.includes(screen.name))

        PanelWindow {
            id: osdWindow
            required property var modelData

            screen: modelData
            visible: root.active
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            implicitWidth: 320
            implicitHeight: 94

            anchors {
                bottom: true
            }
            margins {
                bottom: 64
            }

            mask: Region { item: null }

            Rectangle {
                anchors.fill: parent
                color: Theme.surface
                radius: Theme.radiusLarge
                border.color: Theme.outline
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 14

                    QsIcon {
                        icon: root.icon
                        size: 28
                        color: Theme.primary
                        Layout.preferredWidth: 32
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: root.title
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeBody
                                font.bold: true
                                color: Theme.text
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                visible: root.showLevel
                                text: Math.round(root.value * 100) + "%"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeBody
                                color: Theme.text
                            }
                        }

                        Text {
                            visible: root.detail !== ""
                            text: root.detail
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.textSecondary
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            visible: root.showLevel
                            Layout.fillWidth: true
                            Layout.preferredHeight: 6
                            radius: 3
                            color: Theme.surfaceVariant

                            Rectangle {
                                width: parent.width * Math.max(0, Math.min(1, root.value))
                                height: parent.height
                                radius: parent.radius
                                color: Theme.primary
                            }
                        }
                    }
                }
            }
        }
    }
}
