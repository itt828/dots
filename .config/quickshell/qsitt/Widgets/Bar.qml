import Quickshell
import "../Surfaces"

Scope {
    id: root
    required property var services

    BarHost {
        services: root.services
    }
}
