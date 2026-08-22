import QtQuick

QtObject {
    property bool visible: false
    property bool qrSelecting: false
    property bool qrBusy: false
    property string qrGeometry: ""
    property string qrStatus: "画面上をドラッグしてQRコードを選択します"

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
}
