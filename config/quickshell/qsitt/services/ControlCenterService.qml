pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property bool visible: false
    property int requestedPage: 0
    property bool qrSelecting: false
    property bool qrBusy: false
    property string qrGeometry: ""
    property string qrStatus: "画面上をドラッグしてQRコードを選択します"
    property string pickerStatus: "画面上の1ピクセルを選択します"
    property string pickedColor: ""
    property bool pickerBusy: false
    property string _pickerResult: ""
    property string _qrError: ""

    function toggle() {
        requestedPage = 0;
        NotificationService.panelVisible = false;
        visible = !visible;
    }

    function startQrSelection() {
        if (qrBusy || qrSelecting)
            return;
        visible = false;
        qrStatus = "読み取る範囲をドラッグしてください";
        qrSelecting = true;
    }

    function finishQrSelection(geometry) {
        qrGeometry = geometry;
        qrSelecting = false;
        _qrError = "";
        qrBusy = true;
    }

    function cancelQrSelection() {
        qrSelecting = false;
        qrStatus = "範囲選択をキャンセルしました";
        visible = true;
    }

    function pickColor(): void {
        if (pickerBusy)
            return;
        pickerBusy = true;
        _pickerResult = "";
        pickerStatus = "色を取得する位置を選択してください";
        visible = false;
    }

    function notifyTimer(): void {
        _timerNotificationProcess.running = true;
    }

    readonly property BackendProcess _qrProcess: BackendProcess {
        running: root.qrBusy
        arguments: ["tool", "qr", root.qrGeometry]

        stderr: StdioCollector {
            onStreamFinished: root._qrError = text.trim().slice(0, 160)
        }

        onExited: (exitCode, exitStatus) => {
            root.qrBusy = false;
            if (exitCode === 0)
                root.qrStatus = "QRコードの内容をクリップボードにコピーしました";
            else if (exitCode === 30)
                root.qrStatus = "選択範囲にQRコードが見つかりませんでした";
            else
                root.qrStatus = "QRコードの読み取りに失敗しました";
            if (exitCode !== 0) {
                if (root._qrError !== "")
                    root.qrStatus += "（" + root._qrError + "）";
                root.visible = true;
            }
        }
    }

    readonly property BackendProcess _pickerProcess: BackendProcess {
        running: root.pickerBusy
        arguments: ["tool", "color"]

        stdout: StdioCollector {
            onStreamFinished: root._pickerResult = text.trim()
        }

        onExited: (exitCode, exitStatus) => {
            root.pickerBusy = false;
            if (exitCode === 0) {
                root.pickedColor = root._pickerResult;
                root.pickerStatus = root._pickerResult + " をコピーしました";
            } else if (exitCode === 10)
                root.pickerStatus = "色の選択をキャンセルしました";
            else if (exitCode === 20)
                root.pickerStatus = "必要なコマンドが見つかりません";
            else
                root.pickerStatus = "色の取得に失敗しました";
        }
    }

    readonly property BackendProcess _timerNotificationProcess: BackendProcess {
        arguments: ["tool", "timer-notify"]
    }
}
