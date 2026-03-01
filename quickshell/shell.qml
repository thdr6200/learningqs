import Quickshell
import QtQuick
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick.Layouts

PanelWindow {
    id: root
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 55
    color: "transparent"

    Rectangle {
        id: bar
        color: "#6090ff00"
        border.color: "#ff90ff00"
        width: parent.width*0.9
        height: 40
        anchors {
            top: parent.top
            left: parent.left
            topMargin: (parent.height - height)/2
            leftMargin: (parent.width - width)/2
        }
        topLeftRadius: 10
        topRightRadius: 10
        bottomLeftRadius: 25
        bottomRightRadius: 25

        // Workspaces
        RowLayout {
            id: ws
            anchors {
                top: parent.top
                left: parent.left
                leftMargin: 10
                topMargin: (parent.height - height)/2
            }
            spacing: 2
            Repeater {
                model: 5
                Rectangle {
                    id: currentws
                    property int idx: index+1
                    property var findws: Hyprland.workspaces?.values.find(w => w.id === idx)
                    property bool isActive: Hyprland.focusedWorkspace?.id === idx
                    color: isActive ? '#dbdb27' : '#d53c3c'
                    Layout.minimumWidth: isActive && animateSwitching.start ? animateSwitching.start() && 50 : 17
                    height: 17
                    radius: 10
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("workspace " + idx) && animateSwitching.start()
                    }

                    NumberAnimation {
                        id: animateSwitching
                        target: currentws
                        properties: "Layout.minimumWidth"
                        alwaysRunToEnd: true
                        from: 17
                        to: 50
                        duration: 500
                        easing {type: Easing.OutBack; overshoot: 3}
                    }
                }
            }
        }

    }
}