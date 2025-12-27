import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Scope {
    id: launcher
    
    property bool visible: false
    
    function toggle() {
        visible = !visible
    }
    
    function show() {
        visible = true
    }
    
    function hide() {
        visible = false
    }
    
    LauncherWindow {
        id: launcherWindow
        visible: launcher.visible
        
        PanelWindow {
            anchors.centerIn: parent
            width: 600
            height: 400
            color: "#1a1b26"
            
            Column {
                anchors.fill: parent
                spacing: 10
                padding: 20
                
                TextField {
                    id: searchField
                    width: parent.width - 40
                    placeholderText: "Search applications..."
                    color: "#c0caf5"
                    background: Rectangle {
                        color: "#24283b"
                        radius: 5
                    }
                    
                    onTextChanged: {
                        // Filter applications
                    }
                    
                    Keys.onEscapePressed: {
                        launcher.hide()
                    }
                }
                
                ListView {
                    width: parent.width - 40
                    height: parent.height - searchField.height - 60
                    
                    model: ListModel {
                        ListElement { name: "Terminal"; command: "foot" }
                        ListElement { name: "Firefox"; command: "firefox" }
                        ListElement { name: "Files"; command: "nautilus" }
                    }
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 40
                        color: ListView.isCurrentItem ? "#414868" : "transparent"
                        radius: 5
                        
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            text: model.name
                            color: "#c0caf5"
                            font.pixelSize: 14
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                Process.exec(model.command)
                                launcher.hide()
                            }
                        }
                    }
                }
            }
        }
    }
}
