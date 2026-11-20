pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.ui.theme

QtObject {
    id: root

    property string outputName: ""
    property string geometry: ""
    property string path: ""
    property bool stopping: false
    property string status: ""
    property string recorderError: ""
    readonly property bool recording: recorder.processId > 0
    readonly property bool busy: prepare.running || delay.running || region.running || recorder.running || savedFile.running

    function toggle(output: string): void {
        if (recorder.running)
            stop();
        else
            start(output, false);
    }

    function start(output: string, selectRegion: bool): void {
        if (busy)
            return;
        ControlCenterService.visible = false;
        status = "";
        recorderError = "";
        outputName = output;
        geometry = "";
        stopping = false;
        if (selectRegion)
            delay.start();
        else
            prepare.running = true;
    }

    function stop(): void {
        if (recording && !stopping) {
            stopping = true;
            recorder.signal(2); // SIGINT lets wf-recorder finalize the container.
        }
    }

    function notify(body: string): void {
        status = body;
        reporter.exec(["notify-send", "--app-name=kalumiru", "画面録画", body]);
    }

    readonly property Timer delay: Timer {
        interval: Theme.motionExit + 80
        onTriggered: region.running = true
    }

    readonly property Process region: Process {
        command: ["slurp", "-f", "%x,%y %wx%h"]
        stdout: StdioCollector {
            onStreamFinished: root.geometry = text.trim()
        }
        onExited: code => {
            if (code === 0 && /^-?\d+,-?\d+ [1-9]\d*x[1-9]\d*$/.test(root.geometry))
                prepare.running = true;
        }
    }

    readonly property BackendProcess prepare: BackendProcess {
        arguments: ["tool", "record-path"]
        onStarted: root.path = ""
        stdout: StdioCollector {
            onStreamFinished: root.path = text.trim()
        }
        onExited: code => {
            if (code !== 0 || !root.path) {
                root.notify("録画の準備に失敗しました。wf-recorder と保存先を確認してください。");
                return;
            }
            const args = ["wf-recorder", "--no-dmabuf", "-f", root.path];
            if (root.geometry)
                args.push("-g", root.geometry);
            else if (root.outputName)
                args.push("-o", root.outputName);
            recorder.exec(args);
        }
    }

    readonly property Process recorder: Process {
        stderr: SplitParser {
            onRead: line => {
                if (/error|failed|couldn't|unsupported/i.test(line))
                    root.recorderError = line.trim().slice(0, 240);
            }
        }
        onExited: code => {
            if (code === 0 || (root.stopping && code === 130))
                savedFile.exec(["test", "-s", root.path]);
            else
                root.failed();
            root.stopping = false;
        }
    }

    function failed(): void {
        if (recorderError)
            console.warn("Screen recording:", recorderError);
        notify("録画に失敗しました。出力と画面共有のサポートを確認してください。");
    }

    readonly property Process savedFile: Process {
        onExited: code => {
            if (code === 0)
                root.notify("録画を保存しました: " + root.path.split("/").pop());
            else
                root.failed();
        }
    }

    readonly property Process reporter: Process {}
}
