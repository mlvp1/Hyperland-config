import "../services" 
import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell

Item {
    width: 385
    height: 100
    ColorLoader {
        id: colors
    }
    property string bgColor: colors.bgColor
    property string bgPrimary: colors.bgPrimary
    property string bgSecondary: colors.bgSecondary
    property string bgSecondaryHover: colors.bgSecondaryHover
    property string bgPrimaryDark: colors.bgPrimaryDark
    property string bgSecondaryDark: colors.bgSecondaryDark
    property string bgGradient1: colors.bgGradient1
    property string bgGradient2: colors.bgGradient2
    property string bgGradient3: colors.bgGradient3


    // Gradient border container with bevel effect
 

        // Inner content rectangle
        Rectangle {
            anchors.fill: parent
            anchors.margins: 0
            radius: 20
            color: bgPrimary

            Rectangle {
                id: profilePic
                width: 80
                height: 80
                radius: 40
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                color: bgPrimaryDark
                anchors.leftMargin: 10

                Rectangle {
                    id: gradientBorder
                    width: 85
                    height: 85
                    radius: 40
                    anchors.centerIn: parent
                    rotation: 50
                    opacity: 0

                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop {
                            position: 0
                            color: "#FF0000"
                        }
                        GradientStop {
                            position: 0.16
                            color: "#FF7F00"
                        }
                        GradientStop {
                            position: 0.33
                            color: "#FFFF00"
                        }
                        GradientStop {
                            position: 0.5
                            color: "#00FF00"
                        }
                        GradientStop {
                            position: 0.66
                            color: "#0000FF"
                        }
                        GradientStop {
                            position: 0.83
                            color: "#4B0082"
                        }
                        GradientStop {
                            position: 1
                            color: "#9400D3"
                        }
                    }

                    SequentialAnimation {
                        id: rainbowAnim

                        ParallelAnimation {
                            NumberAnimation {
                                target: gradientBorder
                                property: "opacity"
                                from: 0
                                to: 1
                                duration: 300
                                easing.type: Easing.OutQuad
                            }
                            RotationAnimation {
                                target: gradientBorder
                                property: "rotation"
                                from: gradientBorder.rotation
                                to: gradientBorder.rotation + 360
                                duration: 1000
                                easing.type: Easing.InOutQuad
                            }
                        }

                        NumberAnimation {
                            target: gradientBorder
                            property: "opacity"
                            from: 1
                            to: 0
                            duration: 300
                            easing.type: Easing.InQuad
                        }
                    }
                }

                Image {
                    source: "../icons/cat_pfp.jpg"
                    anchors.centerIn: parent
                    width: 80
                    height: 80
                    fillMode: Image.PreserveAspectCrop
                    clip: true
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: maskRect
                    }
                }

                Rectangle {
                    id: maskRect
                    anchors.fill: parent
                    radius: 50
                    visible: false
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!rainbowAnim.running) {
                            rainbowAnim.start();
                        }
                    }
                }
            }

            // Vertical info stack on the right
            Column {
                anchors.left: profilePic.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Text {
                    text: SystemService.osName
                    font.pixelSize: 18
                    font.bold: true
                    color: bgSecondary
                }

                Text {
                    text: SystemService.username
                    font.pixelSize: 16
                    color: bgSecondaryDark
                }

                Text {
                    text: "Uptime: " + SystemService.uptime
                    font.pixelSize: 14
                    color: bgSecondaryDark
                }
            }
        }


}