import Quickshell
import Quickshell.Io

// All external operations pass arguments directly to the Go backend, without a shell.
Process {
    id: backendProcess
    property list<string> arguments: []
    command: [Quickshell.shellDir + "/backend/qsittd"].concat(backendProcess.arguments)

    function execute(args: var): void {
        backendProcess.arguments = args;
        backendProcess.running = true;
    }
}
