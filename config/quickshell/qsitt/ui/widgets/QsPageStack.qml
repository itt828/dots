pragma ComponentBehavior: Bound
import QtQuick
import qs.ui.theme

Item {
    id: root

    property list<Component> pages
    property int currentIndex: 0
    property bool animate: true
    property var navigationOrder: []
    readonly property bool motionActive: animate && Theme.motionEnabled

    property int selectedIndex: -1
    property int previousIndex: -1
    property int direction: 1
    property real progress: 1
    property real outgoingOpacity: 1
    property real outgoingOffset: 0

    readonly property Item selectedPage: loaders.itemAt(selectedIndex)?.item ?? null
    readonly property Item previousPage: loaders.itemAt(previousIndex)?.item ?? null

    implicitHeight: selectedPage?.implicitHeight ?? previousPage?.implicitHeight ?? 0
    clip: true

    function order(index: int): int {
        const position = navigationOrder.indexOf(index);
        return position >= 0 ? position : index;
    }

    function finish(): void {
        animation.stop();
        previousIndex = -1;
        progress = 1;
    }

    function select(): void {
        if (currentIndex === selectedIndex)
            return;
        if (!motionActive || selectedIndex < 0) {
            finish();
            selectedIndex = currentIndex;
            return;
        }

        animation.stop();
        outgoingOpacity = 0.3 + 0.7 * progress;
        outgoingOffset = direction * (1 - progress) * 14;
        direction = order(currentIndex) >= order(selectedIndex) ? 1 : -1;
        previousIndex = selectedIndex;
        selectedIndex = currentIndex;
        progress = 0;
        animation.start();
    }

    Component.onCompleted: select()
    onCurrentIndexChanged: select()
    onMotionActiveChanged: if (!motionActive)
        finish()

    QsNumberAnimation {
        id: animation

        target: root
        property: "progress"
        to: 1
        onFinished: root.previousIndex = -1
    }

    Repeater {
        id: loaders

        model: root.pages
        delegate: Loader {
            id: page

            required property int index
            required property Component modelData
            readonly property bool front: index === root.selectedIndex
            readonly property bool leaving: index === root.previousIndex
            property bool visited: false

            anchors.fill: parent
            active: front || leaving || visited
            sourceComponent: modelData
            visible: front || leaving
            enabled: front
            z: front ? 1 : 0
            opacity: front ? 0.3 + root.progress * 0.7 : root.outgoingOpacity * (1 - root.progress)
            transform: Translate {
                x: page.front ? root.direction * (1 - root.progress) * 14 : root.outgoingOffset * (1 - root.progress) - root.direction * root.progress * 9
            }

            onLoaded: visited = true
        }
    }
}
