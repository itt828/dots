pragma ComponentBehavior: Bound
import QtCore
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import qs.ui.theme
import qs.ui.widgets
import qs.services
import qs.modules.controlcenter.widgets

ColumnLayout {
    id: root

    required property string outputName
    readonly property bool modalDialogOpen: sectionsStack.selectedPage?.modalDialogOpen ?? false
    readonly property string currentSection: ControlCenterService.settingsSection
    readonly property var sections: [
        {
            key: "display",
            label: "ディスプレイ"
        },
        {
            key: "appearance",
            label: "外観とバー"
        },
        {
            key: "launcher",
            label: "検索"
        },
        {
            key: "notifications",
            label: "通知"
        },
        {
            key: "power",
            label: "電源とセッション"
        }
    ]
    readonly property var outputChoices: [
        {
            value: "",
            label: "全ディスプレイ"
        }
    ].concat(OutputService.screens.map(screen => ({
                value: screen.name,
                label: screen.name
            }))).concat(SettingsService.targetScreens.length > 1 ? [
        {
            value: SettingsService.targetScreens.join(","),
            label: "選択済みの画面"
        }
    ] : [])
    readonly property int outputSelection: outputChoices.findIndex(item => item.value === SettingsService.targetScreens.join(","))

    spacing: 9

    GridLayout {
        id: body
        Layout.fillWidth: true
        columns: root.width < 380 ? 1 : 2
        columnSpacing: 10
        rowSpacing: 8

        Flow {
            Layout.fillWidth: body.columns === 1
            Layout.preferredWidth: body.columns === 2 ? 110 : root.width
            Layout.alignment: Qt.AlignTop
            spacing: 4

            Repeater {
                model: root.sections
                QsButton {
                    required property var modelData
                    width: body.columns === 2 ? 110 : implicitWidth
                    implicitHeight: 31
                    horizontalPadding: 5
                    labelSize: 11
                    text: modelData.label
                    variant: QsButton.Ghost
                    highlighted: root.currentSection === modelData.key
                    highlightColor: Theme.mustard200
                    checkable: true
                    onClicked: ControlCenterService.settingsSection = modelData.key
                }
            }
        }

        QsPageStack {
            id: sectionsStack

            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.alignment: Qt.AlignTop
            currentIndex: Math.max(0, root.sections.findIndex(section => section.key === root.currentSection))
            animate: root.visible
            pages: [displaySettings, appearanceSettings, searchSettings, notificationSettings, powerSettings]
        }
    }

    Component {
        id: displaySettings

        ColumnLayout {
            spacing: 8

            QsSectionLabel {
                text: "接続中のディスプレイ"
            }
            QsPanelCard {
                Repeater {
                    model: OutputService.screens

                    QsDetailRow {
                        required property var modelData
                        title: OutputService.name(modelData)
                        subtitle: OutputService.resolution(modelData) + (modelData.name === root.outputName ? " · この画面" : "")
                        icon: Icons.monitor
                    }
                }
            }

            QsSectionLabel {
                text: "表示とバー"
            }
            QsPanelCard {
                QsDetailRow {
                    title: "バーの表示先"
                    subtitle: "画面ごとのワークスペース"

                    QsChoice {
                        Layout.preferredWidth: 116
                        Accessible.name: "バーの表示先"
                        model: root.outputChoices
                        textRole: "label"
                        valueRole: "value"
                        currentIndex: root.outputSelection
                        displayText: currentIndex < 0 ? SettingsService.targetScreens.join(", ") : currentText
                        onActivated: index => {
                            const output = root.outputChoices[index].value;
                            if (!output)
                                SettingsService.set("targetScreens", []);
                            else if (output !== SettingsService.targetScreens.join(","))
                                SettingsService.set("targetScreens", [output]);
                        }
                    }
                }

                QsDetailRow {
                    title: "夜間モード"
                    subtitle: AppearanceService.nightStatus || (AppearanceService.canSetNight ? "暖色の画面表示" : "wlsunset が必要です")

                    QsSwitch {
                        Accessible.name: "夜間モード"
                        enabled: AppearanceService.canSetNight
                        checked: AppearanceService.nightEnabled
                        onToggled: AppearanceService.toggleNight()
                    }
                }
            }
        }
    }

    Component {
        id: appearanceSettings

        ColumnLayout {
            readonly property bool modalDialogOpen: wallpaperDialog.visible

            spacing: 8
            onEnabledChanged: if (!enabled && wallpaperDialog.visible)
                wallpaperDialog.reject()

            QsPanelCard {
                ThemeSwitcher {
                    Layout.fillWidth: true
                }
            }

            QsSectionLabel {
                text: "トップバー"
            }
            QsPanelCard {
                QsDetailRow {
                    title: "中央のメディア表示"
                    subtitle: "曲名と再生コントロール"

                    QsSwitch {
                        Accessible.name: "中央のメディア表示"
                        checked: SettingsService.barMedia
                        onToggled: checked => SettingsService.set("barMedia", checked)
                    }
                }
                QsDetailRow {
                    title: "概要のメディア表示"

                    QsSwitch {
                        Accessible.name: "概要のメディア表示"
                        checked: SettingsService.showMediaInfo
                        onToggled: checked => SettingsService.set("showMediaInfo", checked)
                    }
                }
            }

            QsSectionLabel {
                text: "動き"
            }

            QsPanelCard {
                QsDetailRow {
                    title: "アニメーション"
                    subtitle: "開閉や切り替えの速さ"

                    QsChoice {
                        Layout.preferredWidth: 108
                        Accessible.name: "アニメーションの速さ"
                        model: [
                            {
                                label: "速い",
                                duration: 140
                            },
                            {
                                label: "標準",
                                duration: 200
                            },
                            {
                                label: "ゆっくり",
                                duration: 300
                            },
                            {
                                label: "なし",
                                duration: 0
                            }
                        ]
                        textRole: "label"
                        valueRole: "duration"
                        currentIndex: model.findIndex(option => option.duration === SettingsService.animationDuration)
                        displayText: currentIndex < 0 ? SettingsService.animationDuration + " ms" : currentText
                        onActivated: index => SettingsService.set("animationDuration", valueAt(index))
                    }
                }
            }

            QsSectionLabel {
                text: "壁紙"
            }
            QsPanelCard {
                QsDetailRow {
                    title: "デスクトップの壁紙"
                    subtitle: AppearanceService.wallpaperStatus || (AppearanceService.canSetWallpaper ? "すべてのディスプレイに適用" : "awww が必要です")

                    QsButton {
                        text: "画像を選ぶ"
                        implicitHeight: 32
                        horizontalPadding: 7
                        labelSize: 11
                        enabled: AppearanceService.canSetWallpaper
                        onClicked: wallpaperDialog.open()
                    }
                }
            }
            FileDialog {
                id: wallpaperDialog

                // Keep the chooser in the layer-shell window so it stacks above the panel.
                options: FileDialog.DontUseNativeDialog
                popupType: Controls.Popup.Item
                title: "壁紙の画像を選ぶ"
                currentFolder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
                fileMode: FileDialog.OpenFile
                nameFilters: ["画像 (*.png *.jpg *.jpeg *.webp *.avif *.bmp *.gif)"]
                onAccepted: AppearanceService.setWallpaper(selectedFile)
            }
        }
    }

    Component {
        id: searchSettings

        ColumnLayout {
            spacing: 8

            QsSectionLabel {
                text: "検索対象のプレフィックス"
            }
            QsPanelCard {
                Repeater {
                    model: SearchService.scopes.slice(1)

                    QsDetailRow {
                        id: searchRow

                        required property var modelData
                        title: modelData.label
                        QsButton {
                            text: searchRow.modelData.prefix
                            toolTip: searchRow.modelData.label + "を検索"
                            implicitHeight: 27
                            horizontalPadding: 9
                            onClicked: {
                                ControlCenterService.visible = false;
                                SearchService.openOnOutput(root.outputName, searchRow.modelData.key);
                            }
                        }
                    }
                }
            }

            QsSectionLabel {
                text: "「/」で対象一覧を表示"
            }
        }
    }

    Component {
        id: notificationSettings

        ColumnLayout {
            spacing: 8

            QsSectionLabel {
                text: "通知ポップアップ"
            }
            QsPanelCard {
                QsDetailRow {
                    title: "表示時間"
                    subtitle: "ポインターやフォーカスで停止"

                    QsChoice {
                        Layout.preferredWidth: 70
                        Accessible.name: "通知の表示時間"
                        textRole: "label"
                        valueRole: "seconds"
                        model: [5, 8, 12, 20].map(seconds => ({
                                    seconds: seconds,
                                    label: seconds + " 秒"
                                }))
                        currentIndex: model.findIndex(option => option.seconds === SettingsService.notificationSeconds)
                        onActivated: index => SettingsService.set("notificationSeconds", valueAt(index))
                    }
                }
                QsDetailRow {
                    title: "おやすみモード"
                    subtitle: "ポップアップを一時停止"

                    QsSwitch {
                        Accessible.name: "おやすみモード"
                        checked: NotificationService.dnd
                        onToggled: checked => NotificationService.dnd = checked
                    }
                }
                QsDetailRow {
                    title: "通知履歴"
                    subtitle: "通知センターで後から確認"

                    QsSwitch {
                        Accessible.name: "通知履歴"
                        checked: SettingsService.notificationHistory
                        onToggled: checked => SettingsService.set("notificationHistory", checked)
                    }
                }
            }

            QsButton {
                text: "サンプル通知を表示"
                icon: Icons.bell
                labelSize: 11
                horizontalPadding: 8
                onClicked: NotificationService.preview()
            }
        }
    }

    Component {
        id: powerSettings

        ColumnLayout {
            spacing: 10

            LidSettings {
                Layout.fillWidth: true
            }
            KeyboardBacklight {
                Layout.fillWidth: true
            }
        }
    }
}
