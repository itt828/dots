import QtQuick

QtObject {
    property bool visible: false
    property bool locked: false
    
    function toggle() {
        visible = !visible
    }

    function lock() {
        locked = true
    }
}
