import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import "../services"
Item {
    height: 30
    width: 30
    ColorLoader {
        id: colors
    }
    property string bgColor: colors.bgColor
    property string bgPrimary: colors.bgPrimary
    property string bgSecondary: colors.bgSecondary
    property string bgSecondaryHover: colors.bgSecondaryHover
    property string bgPrimaryDark: colors.bgPrimaryDark
    property string bgSecondaryDark: colors.bgSecondaryDark
    // Restart process
    Process {
        id: restartProc

        running: false
        command: ["systemctl", "reboot"]
    }

    Rectangle {
        anchors.fill: parent
        color: mouseArea.containsMouse ? bgSecondaryHover : bgSecondary
        radius: 30

        Image {
            id: volumeIcon

            source: "../icons/restart.png" // use a restart icon here
            width: 15
            height: 15
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
            id: mouseArea

            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                restartProc.running = true;
            }
        }

    }

}
