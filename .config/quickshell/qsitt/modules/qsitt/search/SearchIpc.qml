import Quickshell
import Quickshell.Io
import qs.services

Scope {
    IpcHandler {
        target: "search"

        function open(): string {
            SearchService.visible = true;
            return SearchService.visible ? "visible" : "hidden";
        }

        function close(): string {
            SearchService.close();
            return SearchService.visible ? "visible" : "hidden";
        }

        function toggle(): string {
            SearchService.toggle();
            return SearchService.visible ? "visible" : "hidden";
        }

        function lens(): string {
            SearchService.startLensSelection();
            return SearchService.lensSelecting ? "selecting" : "busy";
        }
    }
}
