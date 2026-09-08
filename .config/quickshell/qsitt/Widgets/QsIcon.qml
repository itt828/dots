import QtQuick

Text {
    id: root
    property string icon: ""
    property int size: 16

    font.family: fontLoader.name
    font.pixelSize: size

    width: size
    height: size
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    // Resolve icon string to character using Icons
    text: icon

    FontLoader {
        id: fontLoader
        source: "../Common/Phosphor.ttf"
    }
}
