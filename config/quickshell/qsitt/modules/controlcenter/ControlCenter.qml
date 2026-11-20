pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.modules.controlcenter.widgets
import qs.ui.theme
import qs.services
import qs.ui.widgets
import "pages"

Scope {
    id: root

    readonly property var tabs: [
        {
            page: 0,
            label: "概要"
        },
        {
            page: 5,
            label: "ネットワーク"
        },
        {
            page: 6,
            label: "Bluetooth"
        },
        {
            page: 4,
            label: "音声"
        },
        {
            page: 7,
            label: "設定"
        }
    ]

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData
            readonly property int currentPage: ControlCenterService.requestedPage
            readonly property bool compact: surface.width < 405
            readonly property int padding: compact ? 12 : 18
            readonly property int topInset: Theme.belowBar
            readonly property bool modalDialogOpen: content.selectedPage?.modalDialogOpen ?? false

            screen: modelData
            visible: ControlCenterService.visible || surface.reveal > 0
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "qsitt:control-center"
            WlrLayershell.keyboardFocus: !surface.shown ? WlrKeyboardFocus.None : panel.modalDialogOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand

            mask: dismissArea.inputRegion

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            QsPopupDismissArea {
                id: dismissArea

                output: panel.modelData
                enabled: ControlCenterService.visible
                coverBar: surface.shown && panel.modalDialogOpen
                onPressed: ControlCenterService.visible = false
            }

            QsWindowShadow {
                surface: surface
            }

            Shape {
                id: connector

                readonly property real phase: surface.progress / 0.88

                x: surface.x + surface.width - 104 + surface.offsetX
                y: Theme.barHeight - 1
                width: 72
                height: Math.max(1, surface.y + surface.offsetY - y + 4)
                visible: Theme.motionEnabled && phase > 0 && phase < 1 && (SettingsService.targetScreens.length === 0 || SettingsService.targetScreens.includes(panel.modelData.name))
                opacity: visible ? Math.sin(Math.PI * phase) * 0.65 : 0

                ShapePath {
                    strokeWidth: -1
                    fillColor: Theme.surface
                    startX: 0
                    startY: 0
                    PathCubic {
                        control1X: 29
                        control1Y: 0
                        control2X: 14
                        control2Y: connector.height
                        x: 12
                        y: connector.height
                    }
                    PathLine {
                        x: 60
                        y: connector.height
                    }
                    PathCubic {
                        control1X: 58
                        control1Y: connector.height
                        control2X: 43
                        control2Y: 0
                        x: 72
                        y: 0
                    }
                    PathLine {
                        x: 0
                        y: 0
                    }
                }
            }

            QsPopupSurface {
                id: surface

                shown: ControlCenterService.visible && ControlCenterService.visibleOutput === panel.modelData.name
                anchors {
                    top: parent.top
                    topMargin: panel.topInset
                    right: parent.right
                    rightMargin: Theme.popupInset
                }
                entryX: 10
                entryY: -15
                width: Math.max(1, Math.min(Theme.controlWidth, panel.modelData.width - Theme.popupInset * 2))
                height: Math.max(1, Math.min(panel.modelData.height - anchors.topMargin - 24, panel.padding * 2 + header.implicitHeight + nav.implicitHeight + content.implicitHeight + 24))
                color: Theme.surface
                radius: Theme.radiusLarge
                border.color: Theme.borderPrimary
                border.width: 1
                clip: true
                Behavior on height {
                    enabled: surface.shown && surface.progress >= 0.99
                    QsNumberAnimation {}
                }
                onShownChanged: if (shown)
                    Qt.callLater(() => surface.forceActiveFocus())
                Keys.onEscapePressed: ControlCenterService.visible = false

                MouseArea {
                    anchors.fill: parent
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: panel.padding
                    spacing: 12

                    RowLayout {
                        id: header
                        Layout.fillWidth: true
                        spacing: 8

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3

                            QsMarqueeText {
                                Layout.fillWidth: true
                                text: "コントロールセンター"
                                color: Theme.ink
                                font.family: Theme.fontFamily
                                font.pixelSize: 21
                                font.weight: Font.Bold
                            }
                            QsMarqueeText {
                                Layout.fillWidth: true
                                text: OutputService.label(panel.modelData)
                                color: Theme.muted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }

                        QsButton {
                            visible: panel.currentPage !== 7
                            icon: Icons.settings
                            toolTip: "設定"
                            variant: QsButton.Ghost
                            onClicked: ControlCenterService.openPage(7, panel.modelData.name)
                        }
                        QsButton {
                            icon: Icons.x
                            toolTip: "閉じる"
                            variant: QsButton.Ghost
                            onClicked: ControlCenterService.visible = false
                        }
                    }

                    Rectangle {
                        id: nav
                        Layout.fillWidth: true
                        implicitHeight: 40
                        radius: 12
                        color: Theme.bgTertiary
                        border.color: Theme.borderPrimary

                        readonly property int tabIndex: root.tabs.findIndex(tab => tab.page === panel.currentPage)
                        readonly property Item selectedTab: tabIndex < 0 ? null : tabButtons.itemAt(tabIndex)

                        Rectangle {
                            visible: nav.selectedTab !== null
                            x: nav.selectedTab ? tabRow.x + nav.selectedTab.x : 0
                            y: 4
                            width: nav.selectedTab?.width ?? 0
                            height: nav.height - 8
                            radius: 8
                            color: Theme.bgSecondary

                            Behavior on x {
                                QsNumberAnimation {}
                            }
                            Behavior on width {
                                QsNumberAnimation {}
                            }
                        }

                        RowLayout {
                            id: tabRow
                            anchors.fill: parent
                            anchors.margins: 4
                            spacing: 3

                            Repeater {
                                id: tabButtons
                                model: root.tabs
                                QsButton {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    Layout.fillHeight: true
                                    text: modelData.label
                                    horizontalPadding: panel.compact ? 1 : 6
                                    labelSize: panel.compact ? 10 : 12
                                    variant: QsButton.Ghost
                                    checkable: true
                                    highlighted: panel.currentPage === modelData.page
                                    highlightColor: "transparent"
                                    onClicked: ControlCenterService.requestedPage = modelData.page
                                }
                            }
                        }
                    }

                    QsPageStack {
                        id: content

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        currentIndex: panel.currentPage
                        animate: surface.shown && surface.progress >= 0.99
                        navigationOrder: [0, 1, 2, 3, 5, 6, 4, 7]
                        pages: [
                            Component {
                                HomePage {
                                    compact: panel.compact
                                    outputName: panel.modelData.name
                                    onOpenPage: page => ControlCenterService.requestedPage = page
                                }
                            },
                            Component {
                                ScrollPage {
                                    CalendarWidget {
                                        Layout.fillWidth: true
                                    }
                                }
                            },
                            Component {
                                ScrollPage {
                                    SystemMonitorPage {
                                        Layout.fillWidth: true
                                    }
                                }
                            },
                            Component {
                                ScrollPage {
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 12
                                        TimerStopwatch {
                                            Layout.fillWidth: true
                                        }
                                        ToolList {
                                            Layout.fillWidth: true
                                            controlCenterService: ControlCenterService
                                        }
                                        QsButton {
                                            Layout.fillWidth: true
                                            text: RecorderService.recording ? "録画を停止" : "範囲を選択して画面録画"
                                            icon: Icons.record
                                            enabled: RecorderService.recording || !RecorderService.busy
                                            onClicked: {
                                                if (RecorderService.recording)
                                                    RecorderService.stop();
                                                else
                                                    RecorderService.start(panel.modelData.name, true);
                                            }
                                        }
                                    }
                                }
                            },
                            Component {
                                ScrollPage {
                                    AudioPage {
                                        Layout.fillWidth: true
                                        volumeService: VolumeService
                                    }
                                }
                            },
                            Component {
                                ScrollPage {
                                    NetworkPage {
                                        Layout.fillWidth: true
                                        networkService: NetworkService
                                    }
                                }
                            },
                            Component {
                                ScrollPage {
                                    BluetoothPage {
                                        Layout.fillWidth: true
                                        bluetoothService: BluetoothService
                                    }
                                }
                            },
                            Component {
                                ScrollPage {
                                    modalDialogOpen: settingsPage.modalDialogOpen

                                    SettingsPage {
                                        id: settingsPage

                                        Layout.fillWidth: true
                                        outputName: panel.modelData.name
                                    }
                                }
                            }
                        ]
                    }
                }
            }
        }
    }

    component ScrollPage: Flickable {
        id: scroll
        default property alias pageContent: body.data
        property bool modalDialogOpen: false

        clip: true
        contentWidth: width
        contentHeight: body.implicitHeight
        implicitHeight: contentHeight
        boundsBehavior: Flickable.StopAtBounds
        onVisibleChanged: if (visible)
            contentY = 0

        ColumnLayout {
            id: body
            width: scroll.width
        }

        Controls.ScrollBar.vertical: Controls.ScrollBar {
            policy: Controls.ScrollBar.AsNeeded
        }
    }
}
