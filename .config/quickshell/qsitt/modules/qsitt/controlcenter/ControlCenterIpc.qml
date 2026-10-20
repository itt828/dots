import Quickshell
import Quickshell.Io
import qs.services

Scope {
    IpcHandler {
        target: "control-center"

        function toggle(): string {
            ControlCenterService.toggle();
            return ControlCenterService.visible ? "visible" : "hidden";
        }

        function open(): string {
            ControlCenterService.visible = true;
            return ControlCenterService.visible ? "visible" : "hidden";
        }

        function close(): string {
            ControlCenterService.visible = false;
            return ControlCenterService.visible ? "visible" : "hidden";
        }
    }
}
