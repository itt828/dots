import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland

Rectangle {
	id: root
	required property LockContext context
	
	color: "black"

    // Escape hatch
	Button {
		text: "Emergency Exit"
        visible: false // Hidden by default, enable if debugging
		onClicked: context.unlocked();
        z: 999
	}

	ColumnLayout {
        anchors.centerIn: parent
        spacing: 50

        // Clock
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 0

            Text {
                id: timeLabel
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 96
                color: "white"
                verticalAlignment: Text.AlignVCenter
                
                text: Qt.formatTime(new Date(), "HH:mm")

                Timer {
                    running: true
                    repeat: true
                    interval: 1000
                    onTriggered: timeLabel.text = Qt.formatTime(new Date(), "HH:mm")
                }
            }

            Text {
                id: dateLabel
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 24
                color: "#cccccc"
                verticalAlignment: Text.AlignVCenter
                
                text: Qt.formatDate(new Date(), "dddd, MMMM d")

                Timer {
                    running: true
                    repeat: true
                    interval: 60000 // Update every minute
                    onTriggered: dateLabel.text = Qt.formatDate(new Date(), "dddd, MMMM d")
                }
            }
        }

        // Login Box
		ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 15

			TextField {
				id: passwordBox

				implicitWidth: 300
                implicitHeight: 40
				padding: 10
                horizontalAlignment: TextInput.AlignHCenter

                background: Rectangle {
                    color: "white"
                    radius: 20
                    opacity: 0.2
                    border.color: passwordBox.activeFocus ? "white" : "transparent"
                    border.width: 1
                }

                color: "white"
				focus: true
				enabled: !root.context.unlockInProgress
				echoMode: TextInput.Password
				inputMethodHints: Qt.ImhSensitiveData

                placeholderText: "Password"
                placeholderTextColor: "#88ffffff"

				// Update the text in the context when the text in the box changes.
				onTextChanged: root.context.currentText = this.text;

				// Try to unlock when enter is pressed.
				onAccepted: root.context.tryUnlock();

				// Update the text in the box to match the text in the context.
				Connections {
					target: root.context
					function onCurrentTextChanged() {
						passwordBox.text = root.context.currentText;
					}
				}
			}

            Text {
                visible: root.context.showFailure
                text: "Incorrect password"
                color: "#ff6b6b"
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }
		}
	}
}
