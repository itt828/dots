pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.modules.controlcenter.widgets
import qs.services
import qs.ui.widgets
import qs.ui.theme

ColumnLayout {
    id: root
    required property var volumeService
    spacing: 9

    component Level: RowLayout {
        id: level
        required property string label
        required property real amount
        property string icon: ""
        property bool muted: false
        signal moved(real value)
        signal muteRequested

        Layout.fillWidth: true
        spacing: 8

        QsButton {
            icon: level.icon
            variant: QsButton.Ghost
            implicitWidth: 28
            implicitHeight: 30
            toolTip: level.label + (level.muted ? "のミュートを解除" : "をミュート")
            onClicked: level.muteRequested()
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            QsSectionLabel {
                text: level.label
            }
            QsSlider {
                Layout.fillWidth: true
                implicitHeight: 18
                value: level.amount
                Accessible.name: level.label
                onMoved: value => level.moved(value)
            }
        }
        QsSectionLabel {
            Layout.preferredWidth: 40
            text: level.enabled ? Math.round(level.amount * 100) + "%" : "—"
            horizontalAlignment: Text.AlignRight
        }
    }

    PwObjectTracker {
        objects: root.visible ? root.volumeService.streams : []
    }

    QsSectionLabel {
        text: "デバイス"
    }
    QsPanelCard {
        QsDetailRow {
            title: "出力"
            subtitle: root.volumeService.sinkName
            icon: Icons.volumeHigh
            QsChoice {
                Layout.preferredWidth: 156
                Accessible.name: "音声出力"
                enabled: root.volumeService.sinks.length > 1
                model: root.volumeService.sinks.map(node => ({
                            label: root.volumeService.deviceName(node)
                        }))
                textRole: "label"
                currentIndex: root.volumeService.sinks.indexOf(root.volumeService.sink)
                displayText: root.volumeService.sinkName
                onActivated: index => root.volumeService.setDefaultOutput(root.volumeService.sinks[index])
            }
        }

        QsDetailRow {
            title: "入力"
            subtitle: root.volumeService.sourceName
            icon: Icons.microphone
            QsChoice {
                Layout.preferredWidth: 156
                Accessible.name: "マイク入力"
                enabled: root.volumeService.sources.length > 1
                model: root.volumeService.sources.map(node => ({
                            label: root.volumeService.deviceName(node)
                        }))
                textRole: "label"
                currentIndex: root.volumeService.sources.indexOf(root.volumeService.source)
                displayText: root.volumeService.sourceName
                onActivated: index => root.volumeService.setDefaultInput(root.volumeService.sources[index])
            }
        }

        QsDetailRow {
            visible: root.volumeService.alsaCardName !== ""
            title: "オーディオプロファイル"
            subtitle: root.volumeService.isHeadphones ? "ヘッドホン" : "スピーカー"
            QsButton {
                text: "切り替え"
                implicitHeight: 30
                horizontalPadding: 8
                onClicked: root.volumeService.toggleProfile()
            }
        }
    }

    QsPanelCard {
        Level {
            label: root.volumeService.muted ? "出力音量 · ミュート" : "出力音量"
            icon: root.volumeService.muted ? Icons.volumeMuted : Icons.volumeHigh
            enabled: !!root.volumeService.sink
            amount: root.volumeService.volume
            muted: root.volumeService.muted
            onMuteRequested: root.volumeService.toggleMute()
            onMoved: value => root.volumeService.setVolume(value)
        }
        Level {
            label: root.volumeService.sourceMuted ? "入力レベル · ミュート" : "入力レベル"
            icon: root.volumeService.sourceMuted ? Icons.microphoneSlash : Icons.microphone
            enabled: !!root.volumeService.source
            amount: root.volumeService.sourceVolume
            muted: root.volumeService.sourceMuted
            onMuteRequested: root.volumeService.toggleSourceMute()
            onMoved: value => root.volumeService.setSourceVolume(value)
        }
    }

    QsSectionLabel {
        text: "アプリ別音量"
    }
    QsPanelCard {
        QsSectionLabel {
            visible: root.volumeService.streams.length === 0
            text: "再生中のアプリはありません"
        }

        Repeater {
            model: root.volumeService.streams
            delegate: Level {
                required property var modelData
                label: modelData.properties?.["application.name"] || root.volumeService.deviceName(modelData)
                icon: muted ? Icons.volumeMuted : Icons.mediaMusic
                enabled: !!modelData.audio && modelData.ready
                muted: modelData.audio?.muted ?? false
                amount: modelData.audio?.volume ?? 0
                onMuteRequested: if (modelData.audio)
                    modelData.audio.muted = !modelData.audio.muted
                onMoved: value => {
                    if (modelData.audio)
                        modelData.audio.volume = value;
                }
            }
        }
    }

    MediaControl {
        compact: true
        visible: players.length > 0
    }
}
