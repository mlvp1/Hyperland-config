import "../services"
import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Item {
    property string bgColor: colors.bgColor
    property string bgPrimary: colors.bgPrimary
    property string bgSecondary: colors.bgSecondary
    property string bgSecondaryHover: colors.bgSecondaryHover
    property string bgPrimaryDark: colors.bgPrimaryDark
    property string bgSecondaryDark: colors.bgSecondaryDark

    width: 185
    height: 180

    ColorLoader {
        id: colors
    }



    Rectangle {
        width: 185
        height: 180
        radius: 20

        Rectangle {
            id: root

            anchors.fill: parent
            color: bgPrimary
            radius: 20
            clip: true
            layer.enabled: true

            Rectangle {
                id: mr

                width: root.width
                height: root.height
                radius: 10
                visible: false
            }

            Column {
                anchors.centerIn: parent
                spacing: 5

                // Album cover
                Item {
                    id: cover

                    width: 70
                    height: 70

                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        color: bgPrimaryDark
                    }

                    Rectangle {
                        width: 70
                        height: 70
                        color: "transparent"
                        radius: 20
                        opacity: 0.6
                        layer.enabled: true

                        layer.effect: DropShadow {
                            horizontalOffset: 10
                            verticalOffset: 10
                            radius: 24
                            samples: 32
                            color: "#80000000"
                            transparentBorder: true
                        }

                    }

                    Image {
                        id: img

                        height: parent.height
                        width: parent.width
                        source: MprisService.activeTrack.artUrl
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        clip: true
                        layer.enabled: true

                        layer.effect: OpacityMask {
                            width: cover.width
                            height: cover.height
                            maskSource: maskRect
                        }

                    }

                    Rectangle {
                        id: maskRect

                        anchors.fill: parent
                        radius: 10
                        visible: false
                    }

                }

                // Track info
                Column {
                    spacing: 2
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        id: baseTitle

                        text: MprisService.activeTrack.title
                        font.pixelSize: 18
                        font.bold: true
                        color: bgSecondary
                        width: parent.width
                        elide: Text.ElideRight
                        clip: true
                    }

                    Text {
                        text: MprisService.activeTrack.artist
                        horizontalAlignment: Text.AlignHCenter
                        color: bgSecondaryDark
                        font.pixelSize: 15
                        elide: Text.ElideRight
                    }

                }

                // Control buttons
                Row {
                    // Previous button

                    spacing: 20
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        id: circle

                        width: 40
                        height: 40
                        radius: 20
                        color: mouseArea.containsMouse ? bgSecondaryHover : bgSecondary

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: bgPrimary
                            font.pixelSize: 20
                        }

                        MouseArea {
                            id: mouseArea

                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onPressed: pressAnim.start()
                            onReleased: releaseAnim.start()
                            onClicked: MprisService.previous()
                        }

                        PropertyAnimation {
                            id: pressAnim

                            target: circle
                            property: "scale"
                            to: 0.85
                            duration: 120
                            easing.type: Easing.InOutQuad
                        }

                        SequentialAnimation {
                            id: releaseAnim

                            PropertyAnimation {
                                target: circle
                                property: "scale"
                                to: 1.2
                                duration: 200
                                easing.type: Easing.OutQuad
                            }

                            PropertyAnimation {
                                target: circle
                                property: "scale"
                                to: 1
                                duration: 250
                                easing.type: Easing.OutBounce
                            }

                        }

                    }

                    // Play/Pause button
                    Rectangle {
                        id: circle1

                        width: 40
                        height: 40
                        radius: 10
                        color: mouseArea1.containsMouse ? bgSecondaryHover : bgSecondary

                        Text {
                            anchors.centerIn: parent
                            text: MprisService.isPlaying ? "" : ""
                            color: bgPrimary
                            font.pixelSize: 20
                        }

                        MouseArea {
                            id: mouseArea1

                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onPressed: pressAnim1.start()
                            onReleased: releaseAnim1.start()
                            onClicked: MprisService.togglePlaying()
                        }

                        PropertyAnimation {
                            id: pressAnim1

                            target: circle1
                            property: "scale"
                            to: 0.85
                            duration: 120
                            easing.type: Easing.InOutQuad
                        }

                        SequentialAnimation {
                            id: releaseAnim1

                            PropertyAnimation {
                                target: circle1
                                property: "scale"
                                to: 1.2
                                duration: 200
                                easing.type: Easing.OutQuad
                            }

                            PropertyAnimation {
                                target: circle1
                                property: "scale"
                                to: 1
                                duration: 250
                                easing.type: Easing.OutBounce
                            }

                        }

                    }

                    // Next button
                    Rectangle {
                        id: circle2

                        width: 40
                        height: 40
                        radius: 20
                        color: mouseArea2.containsMouse ? bgSecondaryHover : bgSecondary

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: bgPrimary
                            font.pixelSize: 20
                        }

                        MouseArea {
                            id: mouseArea2

                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onPressed: pressAnim2.start()
                            onReleased: releaseAnim2.start()
                            onClicked: MprisService.next()
                        }

                        PropertyAnimation {
                            id: pressAnim2

                            target: circle2
                            property: "scale"
                            to: 0.85
                            duration: 120
                            easing.type: Easing.InOutQuad
                        }

                        SequentialAnimation {
                            id: releaseAnim2

                            PropertyAnimation {
                                target: circle2
                                property: "scale"
                                to: 1.2
                                duration: 200
                                easing.type: Easing.OutQuad
                            }

                            PropertyAnimation {
                                target: circle2
                                property: "scale"
                                to: 1
                                duration: 250
                                easing.type: Easing.OutBounce
                            }

                        }

                    }

                }

            }

            layer.effect: OpacityMask {
                maskSource: mr
            }

        }

        gradient: Gradient {
            orientation: Gradient.Vertical

            GradientStop {
                position: 0
                color: "#6E5AB0"
            }

            GradientStop {
                position: 0.5
                color: bgPrimary
            }

            GradientStop {
                position: 1
                color: "#35225E"
            }

        }

    }

}
