import Quickshell
import Quickshell.Io

Process {
    id: backendProcess
    property list<string> arguments: []
    command: [Quickshell.shellDir + "/backend/kalumirud"].concat(backendProcess.arguments)

    function execute(args: var): void {
        backendProcess.arguments = args;
        backendProcess.running = true;
    }
}
