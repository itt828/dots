pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.services
import qs.ui.theme
import qs.ui.widgets

ColumnLayout {
    spacing: 10

    QsPanelCard {
        QsDetailRow {
            title: "集中タイマー"
            icon: Icons.clock

            Text {
                text: FocusTimerService.formatTime(FocusTimerService.remaining)
                color: Theme.mustard800
                font.family: "monospace"
                font.pixelSize: 21
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            Repeater {
                model: [1, 5, 10, 25]
                QsButton {
                    required property int modelData
                    Layout.fillWidth: true
                    implicitHeight: 30
                    labelSize: 12
                    horizontalPadding: 6
                    text: modelData + " 分"
                    highlighted: FocusTimerService.duration === modelData * 60
                    enabled: !FocusTimerService.running
                    onClicked: FocusTimerService.setDuration(modelData)
                }
            }

            QsButton {
                implicitHeight: 30
                labelSize: 12
                horizontalPadding: 7
                text: FocusTimerService.running ? "停止" : FocusTimerService.remaining > 0 && FocusTimerService.remaining < FocusTimerService.duration ? "再開" : "開始"
                variant: QsButton.Primary
                onClicked: FocusTimerService.toggle()
            }
        }
    }

    QsPanelCard {
        QsDetailRow {
            title: "ストップウォッチ"
            subtitle: FocusTimerService.formatTime(FocusTimerService.stopwatchMs / 1000)

            QsButton {
                text: FocusTimerService.stopwatchRunning ? "停止" : "開始"
                implicitHeight: 30
                horizontalPadding: 8
                onClicked: FocusTimerService.toggleStopwatch()
            }
            QsButton {
                text: "リセット"
                implicitHeight: 30
                horizontalPadding: 8
                onClicked: FocusTimerService.resetStopwatch()
            }
        }
    }
}
