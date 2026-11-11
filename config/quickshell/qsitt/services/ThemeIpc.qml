import Quickshell
import Quickshell.Io
import qs.services

Scope {
    IpcHandler {
        target: "theme"

        function current(): string {
            return ThemeService.currentPalette + " " + ThemeService.currentMode;
        }

        function list(): string {
            return ThemeService.availablePalettes.map(entry => entry.name).join("\n");
        }

        function set(name: string): string {
            return ThemeService.setPalette(name) ? ThemeService.currentPalette : "unknown palette: " + name;
        }

        function setPalette(name: string): string {
            return ThemeService.setPalette(name) ? ThemeService.currentPalette : "unknown palette: " + name;
        }

        function setMode(mode: string): string {
            return ThemeService.setMode(mode) ? ThemeService.currentMode : "unknown mode: " + mode;
        }

        function toggle(): string {
            return ThemeService.toggleTheme();
        }
    }
}
