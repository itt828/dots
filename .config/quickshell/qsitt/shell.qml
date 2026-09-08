//@ pragma UseQApplication
//@ pragma AppId qsitt
import QtQuick
import Quickshell

ShellRoot {
    id: entrypoint

    Loader {
        id: shellLoader
        asynchronous: true
        source: "QsittShell.qml"
    }
}
