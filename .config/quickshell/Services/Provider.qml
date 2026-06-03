import QtQuick
import "."

QtObject {
    id: root

    readonly property NiriService niri: NiriService {}
    readonly property BrightnessService brightness: BrightnessService {}
    readonly property CpuService cpu: CpuService {}
    readonly property MemService mem: MemService {}
    readonly property VolumeService volume: VolumeService {}
    readonly property NetworkService network: NetworkService {}
    readonly property NotificationStore notifications: NotificationStore {}
    readonly property DashboardContext dashboard: DashboardContext {}
    readonly property PowerContext power: PowerContext {}
    
    readonly property WindowService windows: WindowService { 
        niriService: root.niri 
    }
    
    readonly property WorkspaceStore workspaces: WorkspaceStore { 
        niriService: root.niri 
    }
}
