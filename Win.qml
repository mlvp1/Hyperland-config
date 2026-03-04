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

    width: 60
    height: 30

    ColorLoader {
        id: colors
    }

    Rectangle {
        id: topBar

        anchors.fill: parent
        color: hoverArea.containsMouse ? bgSecondaryHover : bgPrimary
        radius: 30

        Row {
            anchors.centerIn: parent
            spacing: 10

            Image {
                id: wifi

                source: WifiService.connected ? "icons/wifi/wifi_white.png" : "icons/wifi/wifi-slash.png"
                width: 15
                height: 15
                fillMode: Image.PreserveAspectFit

                ColorOverlay {
                    anchors.fill: wifi
                    source: wifi
                    color: hoverArea.containsMouse ? bgPrimary : bgSecondary

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                }

            }

            Image {
                id: bluetooth

                source: "icons/bluetooth/bluetooth_white.png"
                width: 15
                height: 15
                fillMode: Image.PreserveAspectFit

                ColorOverlay {
                    anchors.fill: bluetooth
                    source: bluetooth
                    color: hoverArea.containsMouse ? bgPrimary : bgSecondary

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                }

            }

        }

        MouseArea {
            id: hoverArea

            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: {
                popup.opened = !popup.opened;
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

        width: 400
        height: 350
        visible: false
        color: "transparent"

        anchor {
            item: topBar
            edges: Edges.Bottom
            rect.y: root.y + root.height + 15
        }

        Rectangle {
            id: popupContent

            anchors.fill: parent
            anchors.centerIn: parent
            color: bgColor
            radius: 20
            transformOrigin: Item.TopRight
            opacity: popup.opened ? 1 : 0
            scale: popup.opened ? 1 : 0.92
            layer.enabled: true

            GridLayout {
                anchors.fill: parent
                anchors.centerIn: parent
                anchors.margins: 8
                columns: 2

                // System Info Section
                Rectangle {
                    color: "transparent"
                    radius: 20
                    height: 100
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    Layout.rowSpan: 3

                    SystemInfo {
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        width: 70
                        height: 30
                        color: "transparent"

                        Power {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Restart {
                            anchors.right: parent.right
                            anchors.rightMargin: 35
                            anchors.verticalCenter: parent.verticalCenter
                        }

                    }

                }

                // WiFi Section
                Rectangle {
                    color: bgColor
                    radius: 50
                    height: 85
                    Layout.fillWidth: true

                    Wifi {
                        height: 85
                    }

                }

                // Bluetooth Section
                Rectangle {
                    color: bgColor
                    radius: 20
                    height: 85
                    Layout.fillWidth: true

                    Bluetooth {
                        height: 85
                    }

                }

                // Sound Section
                Rectangle {
                    color: "transparent"
                    radius: 40
                    height: 60
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    Layout.rowSpan: 3

                    Sound {
                        anchors.centerIn: parent
                    }

                }

                // Brightness Section
                Rectangle {
                    color: "transparent"
                    radius: 50
                    height: 60
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    Layout.rowSpan: 3

                    Brightness {
                        anchors.centerIn: parent
                    }

                }

            }

            layer.effect: FastBlur {
                radius: popup.opened ? 0 : 60

                Behavior on radius {
                    NumberAnimation {
                        duration: 50
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.8
                    }

                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutBack
                    easing.overshoot: 0.5
                }

            }

            transform: Translate {
                id: slideTransform

                y: popup.opened ? 0 : -popupContent.height * 0.3

                Behavior on y {
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
