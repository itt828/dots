import QtQuick
import QtQuick.Layouts
import "../Core"

Loader {
    id: root

    required property string moduleName
    required property var moduleContext

    Layout.fillHeight: true
    Layout.alignment: Qt.AlignVCenter

    function loadModule(): void {
        const moduleSource = BarModuleRegistry.sourceFor(root.moduleName);
        if (moduleSource.toString().length === 0) {
            root.source = "";
            return;
        }
        root.setSource(moduleSource, {
            "moduleContext": root.moduleContext
        });
    }

    Component.onCompleted: root.loadModule()
}
