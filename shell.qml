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
        function toggleTopBar() {
            topbar.visible = !topbar.visible;
        }

        target: "topbarr"
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
        id: topbar

        WlrLayershell.namespace: "layer_blur"
        implicitHeight: 44 // it was 44
        color: "transparent"
        visible: true

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
            color: Qt.rgba(Qt.color(bgColor).r, Qt.color(bgColor).g, Qt.color(bgColor).b, 1)
            opacity: 1
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10
            anchors.rightMargin: 10
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

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 61
                        color: bgPrimary
                        height: 30
                        radius: 35

                        ColorPicker {
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        ScreenShot {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                        }

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

            Item {
                anchors.fill: parent

                Notch {
                    anchors.top:parent.top
                    anchors.topMargin:0
                }

            }

        }

    }

}
