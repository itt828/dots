pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as Controls
import QtQuick.Layouts
import qs.modules.notifications as NotificationUi
import qs.ui.theme
import qs.ui.widgets

QsPanelCard {
    id: root

    required property bool previewActive
    property bool popupShown: true
    property bool autoDismiss: false
    property bool actionInvoked: false

    padding: 14
    spacing: 12

    function showPopup(): void {
        actionInvoked = false;
        popup.remaining = popup.duration;
        popupShown = true;
    }

    QtObject {
        id: demo

        readonly property string appName: appNameField.text
        readonly property string summary: titleField.text
        readonly property string body: bodyField.text
        readonly property int expireTimeout: root.autoDismiss ? 5000 : 0
        readonly property var actions: demoAction.text ? [demoAction] : []
    }

    QtObject {
        id: demoAction

        readonly property string text: actionField.text

        function invoke(): void {
            root.actionInvoked = true;
        }
    }

    QsSectionLabel {
        text: "NotificationPopup"
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: popup.implicitHeight + 32
        radius: Theme.radius
        color: Theme.bgPrimary
        clip: true

        QsSectionLabel {
            anchors.centerIn: parent
            visible: !popup.visible
            text: root.actionInvoked ? "アクションを実行しました" : "通知は閉じています"
        }

        QsWindowShadow {
            surface: popup
            blur: 16
            offset: Qt.vector2d(0, 8)
        }

        NotificationUi.NotificationPopup {
            id: popup

            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 12
            width: Math.max(1, Math.min(382, parent.width - 24))
            notification: demo
            shown: root.previewActive && root.visible && root.popupShown
            onClosed: root.popupShown = false
        }
    }

    Flow {
        Layout.fillWidth: true
        spacing: 8

        QsButton {
            text: "再表示"
            variant: QsButton.Primary
            onClicked: root.showPopup()
        }

        QsButton {
            text: "5秒で自動消去"
            checkable: true
            highlighted: root.autoDismiss
            onClicked: {
                root.autoDismiss = !root.autoDismiss;
                root.showPopup();
            }
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width >= 440 ? 2 : 1
        columnSpacing: 10
        rowSpacing: 8

        StoryTextField {
            id: appNameField

            label: "アプリ名"
            text: "kalumiru"
        }

        StoryTextField {
            id: titleField

            label: "通知タイトル"
            text: "更新が完了しました"
        }
    }

    QsSectionLabel {
        text: "通知本文"
    }

    Controls.ScrollView {
        Layout.fillWidth: true
        Layout.preferredHeight: 76
        contentWidth: availableWidth
        Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff

        Controls.TextArea {
            id: bodyField

            text: "コンポーネントのプレビューを更新しました。\n自動消去を有効にすると、通知にマウスを重ねてカウントダウンを一時停止できます。"
            textFormat: TextEdit.PlainText
            wrapMode: TextEdit.Wrap
            padding: 9
            color: Theme.ink
            selectionColor: Theme.accent
            selectedTextColor: Theme.ink
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeBody
            Accessible.name: "通知本文"

            background: Rectangle {
                radius: Theme.radiusSmall
                color: Theme.bgPrimary
                border.color: bodyField.activeFocus ? Theme.focus : Theme.borderPrimary
                border.width: bodyField.activeFocus ? 2 : 1
            }
        }
    }

    StoryTextField {
        id: actionField

        label: "アクションのラベル（空欄で非表示）"
        text: "開く"
    }
}
