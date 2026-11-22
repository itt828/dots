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
    Variants {
        model: Quickshell.screens.filter(screen => SettingsService.targetScreens.length === 0 || SettingsService.targetScreens.includes(screen.name))

        PanelWindow {
            id: barWindow
            required property var modelData
            readonly property bool expanded: width >= Theme.expandedWidth

            screen: modelData
            color: "transparent"
            WlrLayershell.namespace: "kalumiru:bar"
            WlrLayershell.keyboardFocus: ControlCenterService.visible || PowerService.visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            exclusiveZone: Theme.barHeight + Theme.barOuterMargin
            implicitHeight: Math.max(exclusiveZone, Theme.barHeight + Math.ceil(barShadow.blur + barShadow.offset.y))
            mask: Region {
                item: barContent
                radius: barContent.radius
                topLeftRadius: barContent.topLeftRadius
                topRightRadius: barContent.topRightRadius
            }

            anchors {
                top: true
                left: true
                right: true
            }

            QsWindowShadow {
                id: barShadow

                surface: barContent
                topLeftRadius: barContent.topLeftRadius
                topRightRadius: barContent.topRightRadius
                // RectangularShadow needs about 20% more blur for Niri's CSS-style softness of 16.
                blur: 16 * 1.2
                offset: Qt.vector2d(0, 3)
                color: "#60000000"
            }

            BarUi.Base {
                id: barContent
                leftContent: [
                    BarUi.SearchButton {
                        searchService: SearchService
                        outputName: barWindow.modelData.name
                    },
                    BarUi.Workspaces {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        Layout.maximumWidth: implicitWidth
                        workspaceService: WorkspaceService
                        outputName: barWindow.screen.name
                        showOtherOutputs: true
                    },
                    BarUi.WindowTitle {
                        id: windowTitle

                        Layout.fillWidth: true
                        Layout.preferredWidth: Math.min(implicitWidth, 160)
                        Layout.minimumWidth: 0
                        windowService: WindowService
                    },
                    Item {
                        Layout.fillWidth: true
                        visible: !windowTitle.visible
                    }
                ]

                centerContent: BarUi.NowPlaying {
                    id: nowPlaying
                    availableWidth: Math.max(0, barContent.width - 2 * (barContent.rightWidth + barContent.centerTrailingWidth + 16))
                    onTrackActivated: busName => {
                        MediaService.selectedBus = busName;
                        ControlCenterService.openPage(4, barWindow.modelData.name);
                    }
                }

                centerTrailingContent: BarUi.Clock {
                    onClicked: ControlCenterService.openPage(1, barWindow.modelData.name)
                }

                rightContent: [
                    BarUi.Tray {
                        visible: implicitWidth > 0
                        rootWindow: barWindow
                    },
                    QsButton {
                        visible: RecorderService.recording
                        text: "停止"
                        icon: Icons.record
                        toolTip: "画面録画を停止"
                        variant: QsButton.Destructive
                        horizontalPadding: 8
                        onClicked: RecorderService.stop()
                    },
                    BarUi.Notifications {
                        notificationService: NotificationService
                        outputName: barWindow.modelData.name
                    },
                    BarUi.Volume {
                        visible: barWindow.expanded
                        volumeService: VolumeService
                        outputName: barWindow.modelData.name
                    },
                    BarUi.Brightness {
                        visible: barWindow.expanded && BrightnessService.initialized
                        brightnessService: BrightnessService
                    },
                    BarUi.Network {
                        showLabel: barWindow.expanded && !MediaService.playing
                        networkService: NetworkService
                        outputName: barWindow.modelData.name
                    },
                    BarUi.Battery {},
                    QsButton {
                        icon: Icons.settings
                        toolTip: "コントロールセンター"
                        variant: QsButton.Ghost
                        highlighted: ControlCenterService.visible
                        highlightColor: Theme.mustard200
                        onClicked: ControlCenterService.toggle(barWindow.modelData.name)
                    },
                    BarUi.PowerButton {
                        powerService: PowerService
                        outputName: barWindow.modelData.name
                    }
                ]
            }
        }
    }
}
