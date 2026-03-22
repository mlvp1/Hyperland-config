import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import "Widgets"
import "services"

Scope {
    property string bgColor: colors.bgColor
    property string bgPrimary: colors.bgPrimary
    property string bgSecondary: colors.bgSecondary
    property string bgSecondaryHover: colors.bgSecondaryHover
    property string bgPrimaryDark: colors.bgPrimaryDark
    property string bgSecondaryDark: colors.bgSecondaryDark
    property string bgGradient1: colors.bgGradient1
    property string bgGradient2: colors.bgGradient2
    property string bgGradient3: colors.bgGradient3

    ColorLoader {
        id: colors
    }
   
    IpcHandler {
        function toggleTopBarPopup() {
            popup.opened = !popup.opened;
            wallpaper.isopenn = popup.opened;
        }

        function openTopBarPopup() {
            popup.opened = true;
            wallpaper.isopenn = true;
        }

        function closeTopBarPopup() {
            popup.opened = false;
            wallpaper.isopenn = false;
        }

    }

    // Notification overlay window
    PanelWindow {
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "notifications"
        WlrLayershell.exclusiveZone: 0
        width: 480
        height: 400
        visible: Notifications.popupList.length > 0
        color: "transparent"

        anchors {
            right: true
            top: true
        }

        NotificationPopup {
            id: notif
        }

        mask: Region {
            item: notif
        }

    }

    // Main bar window
    PanelWindow {
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "depth-wallpaper-below"
        implicitHeight: 44 // it was 44
        color: "transparent"

        anchors {
            top: true
            left: true
            right: true
        }

        SystemClock {
            id: clock

            precision: SystemClock.Minutes
        }

        Rectangle {
            anchors.fill: parent
            radius: 20
            color: "transparent"
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            anchors.topMargin: 4 // it was 4
            anchors.bottomMargin: 0

            Item {
                width: 120
                height: 44
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: -4

                Row {
                    spacing: 8
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 10

                    Test {
                    }

                    ColorPicker {
                    }

                    ScreenShot {
                    }

                }

            }

            Item {
                width: 140
                height: 44
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: -4

                Row {
                    spacing: 8
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 10

                    Battery {
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Win {
                    }

                }

            }

        }

        Item {
            anchors.fill: parent

            Notch {
                anchors.horizontalCenter: parent.horizontalCenter
            }

        }

    }

}
