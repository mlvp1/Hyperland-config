import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "Widgets"
import "services"

Item {
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
    property bool popupOpened: popup.opened

    width: 100
    height: 30

    IpcHandler {
        function togglePanel() {
            popup.opened = !popup.opened;
            wallpaper.isopenn = popup.opened;
        }

        target: "main"
    }

    ColorLoader {
        id: colors
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Rectangle {
        id: topBar

        anchors.fill: parent
        color: hoverArea.containsMouse ? bgSecondaryHover : bgPrimary
        radius: 30

        Text {
            text: Qt.formatDateTime(clock.date, "hh:mm AP") + "   " + Qt.formatDate(new Date(), "MM/dd")
            font.pointSize: 8
            color: hoverArea.containsMouse ? bgPrimary : bgSecondary
            anchors.centerIn: parent
            font.bold: true

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

        MouseArea {
            id: hoverArea

            hoverEnabled: true
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                popup.opened = !popup.opened;
                wallpaper.isopenn = popup.opened;
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 150
            }

        }

    }

    PanelWindow {
        // Gradient border container with bevel effect

        id: popup

        property bool opened: false

        WlrLayershell.layer: WlrLayershell.Overlay
        WlrLayershell.namespace: "layer_blur"
        width: 540
        height: 1030
        visible: false
        color: "transparent"

        anchors {
            left: true
            top: true
        }

        Rectangle {
            id: popupContent

            border.width: 1
            border.color: bgPrimary
            transformOrigin: Item.TopLeft
            opacity: popup.opened ? 1 : 1
            scale: popup.opened ? 1 : 1
            width: 520
            height: 1010
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.top: parent.top
            anchors.topMargin: 15
            color: Qt.rgba(Qt.color(bgColor).r, Qt.color(bgColor).g, Qt.color(bgColor).b, 1)
            radius: 28
            layer.enabled: true

            GridLayout {
                anchors.fill: parent
                anchors.margins: 10
                columns: 2
                rowSpacing: 10
                columnSpacing: 10
                layer.enabled: true

                Rectangle {
                    color: "transparent"
                    height: 320
                    width: 320
                    radius: 20
                    Layout.rowSpan: 3

                    Calander {
                        anchors.centerIn: parent
                    }

                }

                Rectangle {
                    color: "transparent"
                    height: 330
                    width: 160
                    radius: 20
                    Layout.rowSpan: 3

                    Time {
                    }

                }

                Rectangle {
                    color: "transparent"
                    radius: 20
                    height: 210
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    Layout.rowSpan: 3

                    SS {
                    }

                }

                Rectangle {
                    color: "transparent"
                    radius: 20
                    height: 420
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    Layout.rowSpan: 3

                    Wallpaper {
                        id: wallpaper
                    }

                }

                layer.effect: FastBlur {
                    radius: popup.opened ? 0 : 5

                    Behavior on radius {
                        NumberAnimation {
                            // easing.type: Easing.OutBack
                            // easing.overshoot: 0.8

                            duration: 180
                        }

                    }

                }

            }

            layer.effect: DropShadow {
                horizontalOffset: 4
                verticalOffset: 4
                radius: 10
                samples: 33
                color: "#80000000"
                transparentBorder: true
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutBack
                    easing.overshoot: 0.5
                }

            }

            transform: Translate {
                id: slideTransformBorder

                x: popup.opened ? -10 : -popupContent.width

                Behavior on x {
                    NumberAnimation {
                        duration: 450
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.8
                    }

                }

            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.InOutQuad
                }

            }

        }

        Timer {
            id: hideTimer

            interval: 350
            repeat: false
            onTriggered: {
                if (!popup.opened)
                    popup.visible = false;

            }
        }

        Connections {
            function onOpenedChanged() {
                if (popup.opened) {
                    popup.visible = true;
                    hideTimer.stop();
                } else {
                    hideTimer.start();
                }
            }

            target: popup
        }

    }

}
