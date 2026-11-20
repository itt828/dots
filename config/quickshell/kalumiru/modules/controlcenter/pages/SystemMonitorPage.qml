import QtQuick
import QtQuick.Layouts
import qs.ui.widgets
import qs.ui.theme
import qs.services

ColumnLayout {
    spacing: 8

    QsSectionLabel {
        text: "システムモニター"
    }

    QsPanelCard {
        QsDetailRow {
            title: "CPU"
            icon: Icons.cpu
            subtitle: CpuService.label
        }
        QsProgressBar {
            Layout.fillWidth: true
            value: CpuService.usage
        }
    }

    QsPanelCard {
        QsDetailRow {
            title: "メモリー"
            icon: Icons.ram
            subtitle: MemoryService.label
        }
        QsProgressBar {
            Layout.fillWidth: true
            value: MemoryService.usage
        }
    }
}
