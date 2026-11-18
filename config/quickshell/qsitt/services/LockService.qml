pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
    id: root
    signal unlocked
    signal failed

    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false

    onCurrentTextChanged: showFailure = false

    function reset(): void {
        currentText = "";
        showFailure = false;
    }

    function tryUnlock(password: string): void {
        if (unlockInProgress || password === "")
            return;

        currentText = password;
        root.unlockInProgress = true;
        if (!pam.start()) {
            root.unlockInProgress = false;
            reset();
            root.showFailure = true;
        }
    }

    PamContext {
        id: pam

        configDirectory: "pam"
        config: "password.conf"

        onPamMessage: {
            if (this.responseRequired) {
                this.respond(root.currentText);
            }
        }

        onCompleted: result => {
            if (result == PamResult.Success) {
                root.currentText = "";
                root.unlocked();
            } else {
                root.currentText = "";
                root.showFailure = true;
            }

            root.unlockInProgress = false;
        }
    }
}
