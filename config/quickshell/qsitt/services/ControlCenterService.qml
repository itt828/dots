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

    readonly property Process _qrProcess: Process {
        running: root.qrBusy
        command: ["bash", "-c", `
            value="$(grim -g "$1" -t png - | zbarimg --quiet --raw - 2>/dev/null)"
            [ -n "$value" ] || exit 30
            printf %s "$value" | wl-copy || exit 40
            command -v notify-send >/dev/null && notify-send 'QRコード' 'クリップボードにコピーしました'
        `, "qr-reader", root.qrGeometry]

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

    readonly property Process _pickerProcess: Process {
        running: root.pickerBusy
        command: ["bash", "-c", `
            sleep 0.25
            for tool in slurp grim magick wl-copy; do
                command -v "$tool" >/dev/null || exit 20
            done
            geometry="$(slurp -p -f '%x,%y 1x1')" || exit 10
            [ -n "$geometry" ] || exit 10
            value="$(grim -g "$geometry" -t png - | magick png:- -alpha off -depth 8 -format '#%[hex:p{0,0}]' info:-)"
            [ -n "$value" ] || exit 30
            printf %s "$value" | wl-copy || exit 40
            printf %s "$value"
        `]

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

    readonly property Process _timerNotificationProcess: Process {
        command: ["bash", "-c", "command -v notify-send >/dev/null && notify-send 'タイマー' '設定した時間になりました' -u critical"]
    }
}
