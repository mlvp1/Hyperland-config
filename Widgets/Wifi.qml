import "../services"
import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    property string bgColor: colors.bgColor
    property string bgPrimary: colors.bgPrimary
    property string bgSecondary: colors.bgSecondary
    property string bgSecondaryHover: colors.bgSecondaryHover
    property string bgPrimaryDark: colors.bgPrimaryDark
    property string bgSecondaryDark: colors.bgSecondaryDark

    width: 190
    height: 100

    ColorLoader {
        id: colors
    }

    Rectangle {
        id: mainRect

        anchors.fill: parent
        color: bgPrimary
        radius: 20
        // Apply drop shadow to the main rectangle
        layer.enabled: true

        // Circle fixed on the left
        Rectangle {
            id: circle

            width: 60
            height: 60
            radius: width / 2
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            // Color matches MPRIS theme
            color: hoverArea.containsMouse ? bgSecondaryHover : bgSecondary
            scale: hoverArea.containsMouse ? 1.1 : 1

            Image {
                id: volumeIcon

                source: WifiService.connected ? "../icons/wifi/wifi.png" : "../icons/wifi/wifi-slash.png"
                width: 30
                height: 30
                fillMode: Image.PreserveAspectFit
                smooth: true
                anchors.centerIn: parent

                ColorOverlay {
                    anchors.fill: volumeIcon
                    source: volumeIcon
                    color: bgPrimary
                }

            }

            MouseArea {
                id: hoverArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onPressed: pressAnim.start()
                onReleased: releaseAnim.start()
                onClicked: {
                    // Manual refresh
                    WifiService.connectedSsid = "Refreshing...";
                    WifiService.signalStrength = 0;
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutBack
                    easing.overshoot: 0.5
                }

            }

            // Smooth hover color transition
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

        // Text always to the right of the circle
        Column {
            anchors.left: circle.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Text {
                text: "WI-FI"
                color: bgSecondary
                font.pixelSize: 14
                font.bold: true
            }

            Text {
                text: WifiService.connected ? WifiService.connectedSsid : "No Internet"
                color: bgSecondaryDark
                font.pixelSize: 12
                width: 100
                elide: Text.ElideRight
                clip: true
            }

        }



    }

}
