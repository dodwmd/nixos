import Quickshell
import Quickshell.Wayland
import QtQuick

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            height: 32
            color: "#1a1b26"

            Rectangle {
                anchors.fill: parent
                color: "#1a1b26"

                // Centered time/date
                Text {
                    id: timeText
                    anchors.centerIn: parent
                    text: Qt.formatDateTime(new Date(), "ddd MMM dd  hh:mm:ss")
                    color: "#c0caf5"
                    font.pixelSize: 13
                    font.family: "SF Mono"
                }
            }

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    timeText.text = Qt.formatDateTime(new Date(), "ddd MMM dd  hh:mm:ss")
                }
            }
        }
    }
}
