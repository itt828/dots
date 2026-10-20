pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.modules.common.theme
import qs.modules.qsitt.bar.widgets as BarUi

Scope {
    id: root

    Variants {
        model: Quickshell.screens.filter(screen => SettingsService.targetScreens.length === 0 || SettingsService.targetScreens.includes(screen.name))

        PanelWindow {
            id: barWindow
            required property var modelData

            screen: modelData
            color: "transparent"
            implicitHeight: Theme.barHeight + Theme.barOuterMargin

            anchors {
                top: true
                left: true
                right: true
            }

            BarUi.Base {
                leftContent: RowLayout {
                    spacing: Theme.barModuleSpacing

                    BarUi.SearchButton {
                        searchService: SearchService
                    }
                    BarUi.Workspaces {
                        workspaceService: WorkspaceService
                        outputName: barWindow.screen.name
                        showOtherOutputs: true
                    }
                    BarUi.WindowTitle {
                        windowService: WindowService
                    }
                }

                centerContent: BarUi.Clock {
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ControlCenterService.toggle()
                    }
                }

                rightContent: RowLayout {
                    spacing: Theme.barModuleSpacing

                    BarUi.Tray {
                        rootWindow: barWindow
                    }
                    BarUi.Notifications {
                        notificationService: NotificationService
                    }
                    BarUi.Volume {
                        volumeService: VolumeService
                    }
                    BarUi.Microphone {
                        volumeService: VolumeService
                    }
                    BarUi.Brightness {
                        brightnessService: BrightnessService
                    }
                    BarUi.Network {
                        networkService: NetworkService
                    }
                    BarUi.Battery {}
                    BarUi.PowerButton {
                        powerService: PowerService
                    }
                }
            }
        }
    }
}
