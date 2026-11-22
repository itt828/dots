pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.modules.bar.widgets as BarUi
import qs.ui.widgets

QsPanelCard {
    id: root

    property bool showOtherOutputs: true

    padding: 14
    spacing: 12

    QtObject {
        id: demo

        property var workspaces: [
            {
                output: "DP-1",
                idx: 1,
                name: "作業",
                title: "エディター — kalumiru",
                is_active: true,
                is_focused: true
            },
            {
                output: "DP-1",
                idx: 2,
                name: "ブラウザー",
                title: "コンポーネントギャラリー"
            },
            {
                output: "DP-1",
                idx: 3,
                name: "ターミナル",
                title: "ビルドが完了しました",
                is_urgent: true
            },
            {
                output: "DP-2",
                idx: 1,
                name: "資料",
                title: "デザインメモ",
                is_active: true
            },
            {
                output: "DP-2",
                idx: 2,
                name: "空のワークスペース",
                title: ""
            }
        ]
        readonly property var focused: workspaces.find(workspace => workspace.is_focused)
        readonly property string focusedWindowTitle: focused.title

        function activateWorkspace(output: string, index: int): void {
            workspaces = workspaces.map(workspace => {
                const selected = workspace.output === output && workspace.idx === index;
                return Object.assign({}, workspace, {
                    is_active: workspace.output === output ? selected : workspace.is_active,
                    is_focused: selected,
                    is_urgent: !selected && workspace.is_urgent
                });
            });
        }

        function editFocused(field: string, value: string): void {
            workspaces = workspaces.map(workspace => workspace.is_focused ? Object.assign({}, workspace, {
                    [field]: value
                }) : workspace);
        }
    }

    QsSectionLabel {
        text: "Workspaces / WindowTitle"
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        BarUi.Workspaces {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.maximumWidth: implicitWidth
            workspaceService: demo
            outputName: "DP-1"
            showOtherOutputs: root.showOtherOutputs
        }

        BarUi.WindowTitle {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.preferredWidth: 1
            Layout.maximumWidth: 160
            windowService: demo
        }
    }

    Flow {
        Layout.fillWidth: true
        spacing: 8

        QsButton {
            text: "別出力を表示"
            checkable: true
            highlighted: root.showOtherOutputs
            onClicked: root.showOtherOutputs = !root.showOtherOutputs
        }

        QsSectionLabel {
            height: 36
            verticalAlignment: Text.AlignVCenter
            text: "フォーカス " + demo.focused.output + " / " + demo.focused.idx
        }
    }

    StoryTextField {
        label: "ワークスペース名（読み上げ）"
        text: demo.focused.name
        onTextEdited: value => demo.editFocused("name", value)
    }

    StoryTextField {
        label: "ウィンドウタイトル"
        text: demo.focusedWindowTitle
        onTextEdited: value => demo.editFocused("title", value)
    }
}
