import QtQuick
import QtQuick.Layouts
import qs.ui.theme

Rectangle {
    id: root

    default property alias body: content.data
    property int padding: 11
    property int spacing: 7
    property bool highlighted: false

    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + padding * 2
    radius: 13
    color: highlighted ? Theme.mustard50 : Theme.bgSecondary
    border.color: Theme.borderPrimary
    border.width: 1

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: root.padding
        spacing: root.spacing
    }
}
