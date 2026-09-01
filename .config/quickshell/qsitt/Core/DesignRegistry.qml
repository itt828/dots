pragma Singleton
import QtQuick

QtObject {
    function barSourceFor(name: string): url {
        switch (name) {
        case "default":
            return Qt.resolvedUrl("../Designs/Default/BarSurface.qml");
        case "minimal":
            return Qt.resolvedUrl("../Designs/Minimal/BarSurface.qml");
        default:
            console.warn("Unknown bar design:", name, "- falling back to default");
            return Qt.resolvedUrl("../Designs/Default/BarSurface.qml");
        }
    }
}
