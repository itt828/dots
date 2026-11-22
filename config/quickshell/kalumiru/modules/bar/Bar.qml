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
    function popupTriggerRegion(output: ShellScreen): Region {
        return barWindows.instances.find(window => window.screen === output)?.popupTriggers ?? null;
    }

    component WidgetPill: BarUi.Pill {
        id: pill

        default property alias content: controls.data
        property bool circular: false
        property int horizontalPadding: 4

        implicitWidth: circular ? implicitHeight : controls.implicitWidth + 2 * horizontalPadding

        RowLayout {
            id: controls

            anchors.centerIn: parent
            width: pill.circular ? Math.min(implicitWidth, pill.width) : Math.max(0, pill.width - 2 * pill.horizontalPadding)
            spacing: 0
        }
    }

    Variants {
        id: barWindows

        model: Quickshell.screens.filter(screen => SettingsService.targetScreens.length === 0 || SettingsService.targetScreens.includes(screen.name))

        PanelWindow {
            id: barWindow
            required property var modelData
            readonly property bool expanded: width >= Theme.expandedWidth
            readonly property Region popupTriggers: Region {
                regions: [searchPill.inputRegion, nowPlaying.inputRegion, clockPill.inputRegion,
                    notificationPill.inputRegion, settingsPill.inputRegion, powerPill.inputRegion]
            }

            screen: modelData
            color: "transparent"
            WlrLayershell.namespace: "kalumiru:bar"
            WlrLayershell.keyboardFocus: ControlCenterService.visible || PowerService.visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            exclusiveZone: Theme.barHeight + Theme.barOuterMargin
            implicitHeight: Theme.barHeight + 12
            mask: Region {
                regions: [barWindow.popupTriggers, workspacePill.inputRegion, titlePill.inputRegion,
                    trayPill.inputRegion, recordingPill.inputRegion]
            }

            anchors {
                top: true
                left: true
                right: true
            }

            Item {
                id: barContent

                readonly property int gap: Theme.spacingSmall
                readonly property real centerLimit: rightRow.x - gap
                readonly property real leftRoom: Math.max(0, centerRow.x - gap)
                readonly property real leftReserve: searchPill.width + (workspaces.displayEntries.length > 0 ? gap + Math.min(workspacePill.implicitWidth, 120) : 0)

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: Theme.barOuterMargin
                }
                height: Theme.barPillHeight

                Row {
                    anchors.left: parent.left
                    spacing: barContent.gap

                    WidgetPill {
                        id: searchPill

                        circular: true

                        BarUi.SearchButton {
                            radius: height / 2
                            searchService: SearchService
                            outputName: barWindow.modelData.name
                        }
                    }

                    WidgetPill {
                        id: workspacePill

                        circular: workspaces.displayEntries.length === 1 && !workspaces.displayEntries[0].is_focused
                        horizontalPadding: 2
                        width: Math.max(0, Math.min(implicitWidth, barContent.leftRoom - searchPill.width - barContent.gap))
                        visible: workspaces.displayEntries.length > 0 && width >= (circular ? implicitHeight : 36)

                        BarUi.Workspaces {
                            id: workspaces

                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            color: "transparent"
                            workspaceService: WorkspaceService
                            outputName: barWindow.modelData.name
                            showOtherOutputs: true
                        }
                    }

                    WidgetPill {
                        id: titlePill

                        horizontalPadding: 12
                        width: Math.max(0, Math.min(implicitWidth, 160 + 2 * horizontalPadding, barContent.leftRoom - searchPill.width - barContent.gap - (workspacePill.visible ? workspacePill.width + barContent.gap : 0)))
                        visible: windowTitle.text !== "" && width > 2 * horizontalPadding

                        BarUi.WindowTitle {
                            id: windowTitle

                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            windowService: WindowService
                        }
                    }
                }

                Row {
                    id: centerRow

                    x: Math.max(0, Math.min(barContent.centerLimit - width, Math.max(Math.round((barContent.width - width) / 2), barContent.leftReserve + barContent.gap)))
                    spacing: barContent.gap

                    BarUi.NowPlaying {
                        id: nowPlaying

                        availableWidth: Math.max(0, Math.floor(barContent.centerLimit - barContent.leftReserve - clockPill.width - 2 * barContent.gap))
                        onTrackActivated: busName => {
                            MediaService.selectedBus = busName;
                            ControlCenterService.openPage(4, barWindow.modelData.name);
                        }
                    }

                    WidgetPill {
                        id: clockPill

                        BarUi.Clock {
                            radius: height / 2
                            onClicked: ControlCenterService.openPage(1, barWindow.modelData.name)
                        }
                    }
                }

                Row {
                    id: rightRow

                    anchors.right: parent.right
                    spacing: barContent.gap

                    WidgetPill {
                        id: trayPill

                        circular: tray.itemCount === 1
                        visible: tray.implicitWidth > 0

                        BarUi.Tray {
                            id: tray

                            maximumWidth: Math.min(180, Math.floor(barContent.width * 0.18))
                            rootWindow: barWindow
                        }
                    }

                    WidgetPill {
                        id: recordingPill

                        visible: RecorderService.recording

                        QsButton {
                            text: "停止"
                            icon: Icons.record
                            toolTip: "画面録画を停止"
                            variant: QsButton.Destructive
                            horizontalPadding: 8
                            radius: height / 2
                            onClicked: RecorderService.stop()
                        }
                    }

                    WidgetPill {
                        id: notificationPill

                        circular: notifications.iconOnly

                        BarUi.Notifications {
                            id: notifications

                            radius: height / 2
                            notificationService: NotificationService
                            outputName: barWindow.modelData.name
                        }
                    }

                    WidgetPill {
                        id: settingsPill

                        BarUi.Volume {
                            visible: barWindow.expanded
                            volumeService: VolumeService
                            outputName: barWindow.modelData.name
                        }
                        BarUi.Brightness {
                            visible: barWindow.expanded && BrightnessService.initialized
                            brightnessService: BrightnessService
                        }
                        BarUi.Network {
                            showLabel: barWindow.expanded && !MediaService.playing
                            networkService: NetworkService
                            outputName: barWindow.modelData.name
                        }
                        BarUi.Battery {}
                        QsButton {
                            icon: Icons.settings
                            toolTip: "コントロールセンター"
                            variant: QsButton.Ghost
                            radius: height / 2
                            highlighted: ControlCenterService.visible
                            highlightColor: Theme.mustard200
                            onClicked: ControlCenterService.toggle(barWindow.modelData.name)
                        }
                    }

                    WidgetPill {
                        id: powerPill

                        circular: true

                        BarUi.PowerButton {
                            radius: height / 2
                            powerService: PowerService
                            outputName: barWindow.modelData.name
                        }
                    }
                }
            }
        }
    }
}
