import "../services"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

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

    ColorLoader {
        id: colors
    }
  
    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    FontLoader {
        id: clockFont

        source: "/home/yassine/.config/quickshell/fonts/Blue Winter.ttf"
    }



    Rectangle {
        width: 160

        height: 330
        radius: 20

        Rectangle {
            color: bgPrimary
            height: 330
            width: 160
            radius: 18
            anchors.fill: parent
            anchors.margins: 0

            Column {
                anchors.centerIn: parent
                spacing: 0

                Rectangle {
                    width: 160
                    height: 110
                    color: "transparent"

                    Text {
                        text: Qt.formatDateTime(clock.date, "hh")
                       font.family: clockFont.name
                        font.pointSize: 80
                        font.bold: true
                        color: bgSecondary
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -30

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                                easing.type: Easing.InOutQuad
                            }

                        }

                    }

                }

                Rectangle {
                    width: 160
                    height: 110
                    color: "transparent"

                    Text {
                        text: Qt.formatDateTime(clock.date, "mm")
                        font.family: clockFont.name
                        font.pointSize: 80
                        font.bold: true
                        color: bgSecondary
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: -30

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                                easing.type: Easing.InOutQuad
                            }

                        }

                    }

                }

                Row {
                    spacing: 3
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        text: Qt.formatDate(clock.date, "MM")
                        color: bgSecondary
                        font.pixelSize: 20
                        font.pointSize: 50
                        font.bold: true
                        font.family: font

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                                easing.type: Easing.InOutQuad
                            }

                        }

                    }

                    Text {
                        text: Qt.formatDate(clock.date, "")
                        color: bgSecondary
                        font.pixelSize: 8
                        font.pointSize: 50
                        anchors.verticalCenter: parent.verticalCenter
                        font.bold: true

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                                easing.type: Easing.InOutQuad
                            }

                        }

                    }

                    Text {
                        text: Qt.formatDate(clock.date, "d")
                        color: bgSecondary
                        font.pixelSize: 20
                        font.pointSize: 50
                        font.bold: true

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                                easing.type: Easing.InOutQuad
                            }

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

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }

                }

            }

            GradientStop {
                position: 0.7
                color: bgGradient2

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }

                }

            }

            GradientStop {
                position: 1
                color: bgGradient3

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }

                }

            }

        }

    }

}
