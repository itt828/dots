pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.ui.widgets
import qs.ui.theme
import qs.modules.bar.widgets as BarUi

Scope {
    id: root

    Variants {
        model: Quickshell.screens.filter(screen => SettingsService.targetScreens.length === 0 || SettingsService.targetScreens.includes(screen.name))

        PanelWindow {
            id: barWindow
            required property var modelData

            screen: modelData
            color: "transparent"
            WlrLayershell.namespace: "qsitt:bar"
            BackgroundEffect.blurRegion: Region {
                item: barContent
                radius: barContent.radius
            }
            implicitHeight: Theme.barHeight + Theme.windowShadowPadding
            exclusiveZone: Theme.barHeight
            mask: Region {
                item: barContent
            }

            anchors {
                top: true
                left: true
                right: true
            }

            QsWindowShadow {
                surface: barContent
            }

            BarUi.Base {
                id: barContent
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
                    scale: clockArea.pressed ? 0.97 : 1
                    Behavior on scale {
                        QsNumberAnimation {
                            duration: Theme.motionFast
                        }
                    }
                    MouseArea {
                        id: clockArea
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
                    QsButton {
                        text: "設定"
                        highlighted: ControlCenterService.visible
                        implicitHeight: 28
                        onClicked: ControlCenterService.toggle()
                    }
                    BarUi.PowerButton {
                        powerService: PowerService
                    }
                }
            }
        }
    }
}
