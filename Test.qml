import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
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

    width: 120
    height: 30

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
            text: Qt.formatDateTime(clock.date, "hh:mm AP") + " . " + Qt.formatDate(new Date(), "ddd MM/dd")
            font.pointSize: 8
            font.bold: true
            color: hoverArea.containsMouse ? bgPrimary : bgSecondary
            anchors.centerIn: parent

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

    PopupWindow {
        id: popup

        property bool opened: false

        width: 540
        height: 1030
        visible: false
        color: "transparent"

        anchor {
            item: topBar
            edges: Edges.Bottom
            rect.y: root.y + root.height + 3
            rect.x: -10
        }

        // Gradient border container with bevel effect
        Rectangle {
            id: borderContainer

            anchors.fill: parent
            anchors.margins: 10
            radius: 30
            transformOrigin: Item.TopLeft
            opacity: popup.opened ? 1 : 0
            scale: popup.opened ? 1 : 1

            Rectangle {
                id: popupContent

                anchors.fill: parent
                anchors.margins: 0
                color: bgColor
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
                        color: bgPrimaryDark
                        height: 320
                        width: 320
                        radius: 20
                        Layout.rowSpan: 3

                        Calander {
                            anchors.centerIn: parent
                        }

                    }

                    Rectangle {
                        color: bgPrimaryDark
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
                        height: 250
                        Layout.fillWidth: true
                        Layout.columnSpan: 2
                        Layout.rowSpan: 3

                        ThemeSwitcher {
                        }

                    }

                    Rectangle {
                        color: "red"
                        radius: 20
                        height: 380
                        Layout.fillWidth: true
                        Layout.columnSpan: 2
                        Layout.rowSpan: 3

                        Wallpaper {
                            id: wallpaper
                        }

                    }

                    layer.effect: FastBlur {
                        radius: popup.opened ? 0 : 80

                        Behavior on radius {
                            NumberAnimation {
                                // easing.type: Easing.OutBack
                                // easing.overshoot: 0.8

                                duration: 250
                            }

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

            gradient: Gradient {
                orientation: Gradient.Vertical

                GradientStop {
                    position: 0
                    color: bgGradient1
                }

                GradientStop {
                    position: 0.7
                    color: bgGradient2
                }

                GradientStop {
                    position: 1
                    color: bgGradient3
                }

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
                        duration: 550
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.6
                    }

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
