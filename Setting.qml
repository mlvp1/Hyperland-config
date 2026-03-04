import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "Widgets"
import "services"

FloatingWindow {
    id: root

    property string bgColor: colors.bgColor
    property string bgPrimary: colors.bgPrimary
    property string bgSecondary: colors.bgSecondary
    property string bgSecondaryHover: colors.bgSecondaryHover
    property string bgPrimaryDark: colors.bgPrimaryDark
    property string bgSecondaryDark: colors.bgSecondaryDark
    property string bgGradient1: colors.bgGradient1
    property string bgGradient2: colors.bgGradient2
    property string bgGradient3: colors.bgGradient3

    color: bgPrimary

    ColorLoader {
        id: colors
    }

    Rectangle {
        height: parent.height
        anchors.left: parent.left
        width: 480
        color: "white"

        Column {
            Rectangle {
                width: 480
                height: 100
                color: "green"

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        wallpaper.visible = !wallpaper.visible;
                    }
                }

            }

            Rectangle {
                width: 480
                height: 100
                color: "red"

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        wallpaper.visible = !wallpaper.visible;
                    }
                }

            }

        }

    }

    Rectangle {
        anchors.right: parent.right
        width: 1420
        height: parent.height
        color: "red"

        WallpaperTest {
            id: wallpaper

            visible: true
        }

    }

}
