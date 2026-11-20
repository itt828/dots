pragma ComponentBehavior: Bound
import QtQuick
import qs.ui.theme
import qs.ui.widgets

Rectangle {
    id: root

    required property var workspaceService
    property string outputName: ""
    property bool showOtherOutputs: false
    readonly property int buttonSize: 24
    readonly property int buttonRadius: 6

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

    readonly property int activeIndex: displayEntries.findIndex(workspace => workspace?.output === outputName && workspace.is_active)
    property bool markerVisible: false
    property bool markerFocused: false
    property real markerX: 0

    function placeMarker(): void {
        const entry = workspaceRepeater.itemAt(activeIndex);
        if (!entry) {
            markerVisible = false;
            return;
        }

        markerX = entry.x;
        markerFocused = entry.focused;
        markerVisible = true;
    }

    onDisplayEntriesChanged: Qt.callLater(placeMarker)

    color: Theme.bgTertiary
    radius: 11
    visible: displayEntries.length > 0
    implicitWidth: workspaceRow.implicitWidth + 8
    implicitHeight: buttonSize + 8

    Flickable {
        anchors.fill: parent
        anchors.margins: 4
        clip: true
        contentWidth: workspaceRow.implicitWidth
        contentHeight: height
        flickableDirection: Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentWidth > width

        Rectangle {
            id: marker

            x: root.markerX
            width: root.buttonSize
            height: root.buttonSize
            anchors.verticalCenter: workspaceRow.verticalCenter
            radius: root.buttonRadius
            visible: root.markerVisible
            color: root.markerFocused ? Theme.mustard800 : Theme.bgSecondary
            border.color: Theme.mustard800
            border.width: root.markerFocused ? 0 : 1

            Behavior on x {
                enabled: marker.visible
                QsNumberAnimation {}
            }
        }

        Row {
            id: workspaceRow

            height: parent.height
            spacing: 4

            Repeater {
                id: workspaceRepeater

                model: root.displayEntries
                onItemAdded: Qt.callLater(root.placeMarker)
                onItemRemoved: Qt.callLater(root.placeMarker)

                Rectangle {
                    id: entry

                    required property var modelData
                    readonly property bool divider: modelData === null
                    readonly property bool local: !divider && modelData.output === root.outputName
                    readonly property bool selected: !divider && (modelData.is_active ?? false)
                    readonly property bool focused: !divider && (modelData.is_focused ?? false)
                    readonly property bool urgent: !divider && (modelData.is_urgent ?? false) && !focused
                    readonly property bool overMarker: local && marker.visible && x + width / 2 >= marker.x && x + width / 2 < marker.x + marker.width
                    readonly property bool filled: overMarker ? root.markerFocused : selected && !local && focused
                    readonly property bool outlined: selected && !local && !focused

                    onXChanged: if (local && selected)
                        Qt.callLater(root.placeMarker)
                    width: divider ? 1 : root.buttonSize
                    height: divider ? 16 : root.buttonSize
                    anchors.verticalCenter: parent.verticalCenter
                    radius: root.buttonRadius
                    color: {
                        if (divider)
                            return Theme.borderPrimary;
                        if (selected && !local)
                            return focused ? Theme.mustard800 : Theme.bgSecondary;
                        if (urgent && !overMarker)
                            return Theme.errorSurface;
                        return "transparent";
                    }
                    border.width: activeFocus ? 2 : outlined || (!divider && !overMarker && !selected) ? 1 : 0
                    border.color: activeFocus ? Theme.focus : outlined ? Theme.mustard800 : Theme.border
                    activeFocusOnTab: !divider
                    Accessible.ignored: divider
                    Accessible.role: Accessible.Button
                    Accessible.name: divider ? "" : modelData.name || "ワークスペース " + modelData.idx
                    Accessible.selected: selected
                    Accessible.onPressAction: activate()

                    function activate(): void {
                        if (!divider)
                            root.workspaceService.activateWorkspace(modelData.output, modelData.idx);
                    }

                    QsHoverBackground {
                        hovered: !entry.divider && area.containsMouse
                        anchors.margins: entry.border.width
                        radius: entry.radius
                        color: entry.filled ? Theme.withAlpha(Theme.surface, 0.16) : entry.overMarker || entry.outlined ? Theme.withAlpha(Theme.ink, 0.06) : Theme.hover
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
