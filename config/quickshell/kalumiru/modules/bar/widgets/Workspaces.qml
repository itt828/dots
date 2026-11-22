pragma ComponentBehavior: Bound
import QtQuick
import qs.ui.theme
import qs.ui.widgets

Rectangle {
    id: root

    required property var workspaceService
    property string outputName: ""
    property bool showOtherOutputs: false
    readonly property int buttonWidth: 16
    readonly property int buttonHeight: 24
    readonly property int dividerWidth: 17
    readonly property int dotSize: 9
    readonly property int focusedExtraWidth: 20

    readonly property var displayEntries: {
        const all = workspaceService.workspaces || [];
        const outputs = [outputName];
        if (showOtherOutputs) {
            for (const workspace of all) {
                if (workspace.output && !outputs.includes(workspace.output))
                    outputs.push(workspace.output);
            }
        }

        const entries = [];
        for (const output of outputs) {
            const workspaces = all.filter(workspace => workspace.output === output).sort((a, b) => a.idx - b.idx);
            if (workspaces.length === 0)
                continue;
            if (entries.length > 0)
                entries.push(null);
            entries.push(...workspaces);
        }
        return entries;
    }

    color: Theme.bgTertiary
    radius: 11
    visible: displayEntries.length > 0
    implicitWidth: workspaceRow.implicitWidth + 8
    implicitHeight: buttonHeight + 8

    Flickable {
        anchors.fill: parent
        anchors.margins: 4
        clip: true
        contentWidth: workspaceRow.implicitWidth
        contentHeight: height
        flickableDirection: Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentWidth > width

        Row {
            id: workspaceRow

            height: parent.height
            spacing: 2

            Repeater {
                model: root.displayEntries.length

                Item {
                    id: entry

                    required property int index
                    readonly property var workspace: root.displayEntries[index] ?? null
                    readonly property bool divider: workspace === null
                    readonly property bool focused: workspace?.is_focused ?? false
                    readonly property bool selected: focused || (workspace?.is_active ?? false)
                    readonly property bool urgent: workspace?.is_urgent ?? false

                    width: divider ? root.dividerWidth : root.buttonWidth + (focused ? root.focusedExtraWidth : 0)
                    height: root.buttonHeight
                    anchors.verticalCenter: parent.verticalCenter
                    activeFocusOnTab: !divider
                    Accessible.ignored: divider
                    Accessible.role: Accessible.Button
                    Accessible.name: divider ? "" : workspace.name || "ワークスペース " + workspace.idx
                    Accessible.selected: selected
                    Accessible.onPressAction: activate()

                    function activate(): void {
                        if (!divider)
                            root.workspaceService.activateWorkspace(workspace.output, workspace.idx);
                    }

                    Behavior on width {
                        enabled: !entry.divider
                        QsNumberAnimation {}
                    }

                    QsHoverBackground {
                        hovered: !entry.divider && area.containsMouse
                        anchors.margins: 1
                        radius: height / 2
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: entry.divider ? 1 : Math.max(root.dotSize, entry.width - root.buttonWidth + root.dotSize)
                        height: entry.divider ? 16 : root.dotSize
                        radius: entry.divider ? 0 : height / 2
                        color: entry.divider ? Theme.borderPrimary : entry.selected ? Theme.mustard800 : "transparent"
                        border.width: entry.divider ? 0 : entry.activeFocus ? 2 : entry.selected ? 0 : 1
                        border.color: entry.activeFocus ? Theme.focus : entry.urgent ? Theme.error : Theme.muted
                    }

                    MouseArea {
                        id: area
                        anchors.fill: parent
                        enabled: !entry.divider
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: entry.activate()
                    }
                    Keys.onSpacePressed: activate()
                    Keys.onReturnPressed: activate()
                }
            }
        }
    }
}
