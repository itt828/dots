pragma Singleton
import QtQuick

QtObject {
    // 表示するモニターのリスト（空の場合はすべてのモニターに表示）
    readonly property var targetScreens: ["eDP-1"]

    // アニメーション速度などの共通設定
    readonly property int animationDuration: 200

    // デバッグフラグ
    readonly property bool debug: false
}
