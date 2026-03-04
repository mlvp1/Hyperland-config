import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "services"

RowLayout {
    id: workspaceBar
    
anchors.margins: 5
    property string bgColor: colors.bgColor
    property string bgPrimary: colors.bgPrimary
    property string bgSecondary: colors.bgSecondary
    property string bgSecondaryHover: colors.bgSecondaryHover
    property string bgPrimaryDark: colors.bgPrimaryDark
    property string bgSecondaryDark: colors.bgSecondaryDark

    spacing: 0

    ColorLoader {
        id: colors
    }

    Rectangle {
        anchors.fill: parent
        anchors.centerIn: parent
        anchors.margins: 0
        color: "transparent"
        radius: 80
    }

    Repeater {
        model: Hyprland.workspaces

        MouseArea {
            id: workspaceButton

            required property var modelData

            Layout.leftMargin: workspaceButton.containsMouse && modelData.active || modelData.focused ? 11 : 0
            Layout.rightMargin: workspaceButton.containsMouse && modelData.active || modelData.focused ? 10 : 0
            width: 20
            height: 28
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            z: 10
            onClicked: {
                Quickshell.execDetached(["hyprctl", "dispatch", "workspace", modelData.name]);
            }

            Rectangle {
                id: workspaceDot

                anchors.centerIn: parent
                
                width: modelData.focused || modelData.active ? 35 : 15
                height: modelData.focused || modelData.active ? 18 : 15
                radius: width / 2
                color: workspaceButton.containsMouse ? bgSecondaryHover : (modelData.focused || modelData.active ? bgPrimary : bgPrimaryDark)
                scale: workspaceButton.containsMouse ? 1.1 : 1

                Text {
                    anchors.centerIn: parent
                    text: modelData.id
                    font.pixelSize: modelData.focused ? 15 : 10
                    color: workspaceButton.containsMouse && modelData.focused  ? bgPrimary : (modelData.focused || modelData.active ? bgSecondary : "transparent")
                    font.bold: true

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                            easing.type: Easing.InOutQuad
                        }

                    }

                }

                // Faster size animations
                Behavior on width {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutQuad
                    }

                }

                Behavior on height {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutQuad
                    }

                }

                // Faster color transitions
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }

                }

            }

            // Faster margin animations
            Behavior on Layout.leftMargin {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutQuad
                }

            }

            Behavior on Layout.rightMargin {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutQuad
                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutBack
                    easing.overshoot: 0.5
                }

            }

        }

    }

}
