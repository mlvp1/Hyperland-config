import "../services"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: button

    property string bgColor: colors.bgColor
    property string bgPrimary: colors.bgPrimary
    property string bgSecondary: colors.bgSecondary
    property string bgSecondaryHover: colors.bgSecondaryHover
    property string bgPrimaryDark: colors.bgPrimaryDark
    property string bgSecondaryDark: colors.bgSecondaryDark

    width: 30
    height: 30
    radius: 30
    color: mouseArea.containsMouse ? bgSecondaryHover : bgPrimary

    ColorLoader {
        id: colors
    }

    Text {
        anchors.centerIn: parent
        text: ""
        color: mouseArea.containsMouse ? bgPrimary : bgSecondary
        font.pixelSize: 15
        font.bold: true

        Behavior on color {
            ColorAnimation {
                duration: 150
            }

        }

    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            Quickshell.execDetached(["hyprpicker", "-a"]);
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 150
        }

    }

}
