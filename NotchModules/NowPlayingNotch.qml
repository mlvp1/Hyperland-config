import "../services"
// NowPlayingNotch.qml
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import Quickshell.Services.Mpris

Item {
    id: nowPlayingNotch

    property real size: 1

    // Album art on the left
    Item {
        id: albumArtNotch

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 10
        anchors.topMargin: 4
        width: 25
        height: 25
        opacity: parent.visible ? 1 : 0
        scale: parent.visible ? size : 0.8
        z: 6
        layer.enabled: true

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: "#1a1a1a"

            Image {
                id: notchAlbumArt

                source: MprisService.activeTrack.artUrl
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                smooth: true
                layer.enabled: true

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onDoubleClicked: MprisService.next()
                    onClicked: MprisService.togglePlaying()
                }

                layer.effect: OpacityMask {

                    maskSource: Rectangle {
                        width: notchAlbumArt.width
                        height: notchAlbumArt.height
                        radius: 6
                    }

                }

            }

        }


        layer.effect: FastBlur {
            radius: parent.visible ? 0 : 50

            Behavior on radius {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }

            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: 350
                easing.type: Easing.InOutQuad
            }

        }
              Behavior on scale {
            NumberAnimation {
                duration: 400
            easing.type: Easing.InOutCubic
            }

        }

 

    }

    // Animated wave icon on the right
    Item {
        id: songIcon

        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 10
        anchors.topMargin: 4
        width: 25
        height: 25
        opacity: parent.visible ? 1 : 1
        scale: parent.visible ? size : 0.8
        z: 6
        layer.enabled: true

        AnimatedImage {
            source: "../icons/wave.gif"
            width: 25
            height: 25
            playing: true
        }

        layer.effect: FastBlur {
            radius: parent.visible ? 0 : 50

            Behavior on radius {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }

            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: 350
                easing.type: Easing.InOutQuad
            }

        }

       Behavior on scale {
            NumberAnimation {
                duration: 400
                      easing.type: Easing.InOutCubic
            }

        }
    }

}
