pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

QtObject {
    // 表示するモニターのリスト（空の場合はすべてのモニターに表示）
    readonly property var targetScreens: ["eDP-1"]

    // アニメーション速度などの共通設定
    readonly property int animationDuration: 200

    // デバッグフラグ
    readonly property bool debug: false

    // Barの見た目と配置は独立して変更できる。
    readonly property string barDesign: "default"
    readonly property var barLayout: ({
            "left": ["search", "workspaces", "windowTitle"],
            "center": ["clock"],
            "right": ["tray", "notifications", "volume", "microphone", "brightness", "network", "battery", "power"]
        })
}
