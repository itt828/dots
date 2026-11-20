pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

QtObject {
    readonly property string fontFamily: regularFont.name
    readonly property FontLoader regularFont: FontLoader {
        source: "../../assets/fonts/Phosphor.ttf"
    }

    readonly property string batteryCharging: "\ue0ba"
    readonly property string batteryFull: "\ue0c0"
    readonly property string batteryHigh: "\ue0c2"
    readonly property string batteryMedium: "\ue0c6"
    readonly property string batteryLow: "\ue0c4"

    readonly property string wifiSlash: "\ue4f2"
    readonly property string wifiX: "\ue4f4"
    readonly property string wifiNone: "\ue4f0"
    readonly property string wifiLow: "\ue4ec"
    readonly property string wifiMedium: "\ue4ee"
    readonly property string wifiHigh: "\ue4ea"

    readonly property string network: "\uedde"
    readonly property string networkSlash: "\ueddc"
    readonly property string bluetooth: "\ue0da"

    readonly property string sun: "\ue472"
    readonly property string sunDim: "\ue474"

    readonly property string volumeMuted: "\ue45a"
    readonly property string volumeLow: "\ue44e"
    readonly property string volumeMedium: "\ue44c"
    readonly property string volumeHigh: "\ue44a"

    readonly property string microphone: "\ue326"
    readonly property string microphoneSlash: "\ue328"

    readonly property string mediaPrev: "\ue5a4"
    readonly property string mediaPlay: "\ue3d0"
    readonly property string mediaPause: "\ue39e"
    readonly property string mediaNext: "\ue5a6"
    readonly property string mediaMusic: "\ue33c"

    readonly property string applications: "\ue464"
    readonly property string folder: "\ue25a"
    readonly property string clipboard: "\ue196"
    readonly property string calculator: "\ue538"
    readonly property string globe: "\ue288"
    readonly property string moon: "\ue330"
    readonly property string monitor: "\ue32e"
    readonly property string record: "\ue3ee"
    readonly property string cpu: "\ue610"
    readonly property string ram: "\ue9c4"

    readonly property string clock: "\ue19a"
    readonly property string search: "\ue30c"

    readonly property string bell: "\ue0ce"
    readonly property string bellRinging: "\ue5e8"
    readonly property string bellSlash: "\ue0d4"

    readonly property string power: "\ue3da"
    readonly property string lock: "\ue2fa"
    readonly property string settings: "\ue434"

    readonly property string caretRight: "\ue13a"
    readonly property string caretDown: "\ue136"
    readonly property string x: "\ue4f6"
}
