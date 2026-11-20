import QtQuick
import qs.ui.theme

Item {
    id: root

    property alias text: label.text
    property alias font: label.font
    property alias color: label.color
    property alias textFormat: label.textFormat
    property alias wrapMode: label.wrapMode
    property alias maximumLineCount: label.maximumLineCount
    property alias elideMode: label.elide
    property alias verticalAlignment: label.verticalAlignment
    property bool hovered: pointer.hovered

    readonly property bool multiline: wrapMode !== Text.NoWrap
    readonly property real distance: multiline ? fullText.implicitHeight - height : fullText.implicitWidth - width
    readonly property bool scrolling: visible && hovered && distance > 1 && Theme.motionEnabled
    property real scrollOffset: 0

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight
    clip: true
    Accessible.role: Accessible.StaticText
    Accessible.name: text

    onScrollingChanged: {
        scroll.stop();
        scrollOffset = 0;
        if (scrolling)
            scroll.start();
    }
    onTextChanged: {
        if (scrolling) {
            scrollOffset = 0;
            scroll.restart();
        }
    }

    HoverHandler {
        id: pointer
    }

    Text {
        id: label
        anchors.fill: parent
        visible: !root.scrolling
        Accessible.ignored: true
        textFormat: Text.PlainText
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        id: fullText

        x: root.multiline ? 0 : -root.scrollOffset
        y: root.multiline ? -root.scrollOffset : (root.height - height) / 2
        width: root.multiline ? root.width : implicitWidth
        text: label.text
        font: label.font
        color: label.color
        textFormat: label.textFormat
        wrapMode: label.wrapMode
        visible: root.scrolling
        Accessible.ignored: true
    }

    SequentialAnimation {
        id: scroll
        loops: Animation.Infinite
        PauseAnimation {
            duration: 300
        }
        NumberAnimation {
            target: root
            property: "scrollOffset"
            from: 0
            to: Math.max(0, root.distance)
            duration: Math.max(240, Math.round(root.distance * (root.multiline ? 34 : 21)))
        }
        PauseAnimation {
            duration: 750
        }
        NumberAnimation {
            target: root
            property: "scrollOffset"
            to: 0
            duration: 0
        }
    }
}
