pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

QtObject {
    function barSourceFor(name: string): url {
        switch (name) {
        case "default":
            return Qt.resolvedUrl("../Modules/Bar/Designs/Default.qml");
        case "minimal":
            return Qt.resolvedUrl("../Modules/Bar/Designs/Minimal.qml");
        default:
            console.warn("Unknown bar design:", name, "- falling back to default");
            return Qt.resolvedUrl("../Modules/Bar/Designs/Default.qml");
        }
    }
}
