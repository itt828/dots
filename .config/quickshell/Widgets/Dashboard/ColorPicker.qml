import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../Assets"

Rectangle {
    id: root

    required property var dashboardContext
    property bool busy: false
    property string status: "画面上の1ピクセルを選択します"
    property string pickedColor: ""
    property string resultColor: ""

    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 24
    radius: 8
    color: "#ffffff"

    RowLayout {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: 12
        }
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 42
            Layout.preferredHeight: 42
            radius: 8
            color: root.pickedColor !== "" ? root.pickedColor : "#e3f2fd"
            border.width: 1
            border.color: "#cfd8dc"
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Text {
                Layout.fillWidth: true
                text: "カラーピッカー"
                color: "#263238"
                font.bold: true
            }

            Text {
                Layout.fillWidth: true
                text: root.status
                color: root.busy ? Theme.accent : "#607d8b"
                font.pointSize: 9
                wrapMode: Text.Wrap
            }
        }

        Text {
            text: root.busy ? "…" : "実行"
            color: root.busy ? "#90a4ae" : Theme.accent
            font.bold: true
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: !root.busy
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            root.busy = true
            root.resultColor = ""
            root.status = "色を取得する位置を選択してください"
            root.dashboardContext.visible = false
        }
    }

    Process {
        id: pickerProcess
        running: root.busy
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
            onStreamFinished: {
                const value = text.trim()
                if (value !== "")
                    root.resultColor = value
            }
        }

        onExited: (exitCode, exitStatus) => {
            root.busy = false
            if (exitCode === 0) {
                root.pickedColor = root.resultColor
                root.status = root.resultColor + " をコピーしました"
            }
            else if (exitCode === 10)
                root.status = "色の選択をキャンセルしました"
            else if (exitCode === 20)
                root.status = "必要なコマンドが見つかりません"
            else
                root.status = "色の取得に失敗しました"
        }
    }
}
