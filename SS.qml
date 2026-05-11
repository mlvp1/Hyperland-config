import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import "services"

Item {
    id: window

    property string bgColor: colors.bgColor
    property string bgPrimary: colors.bgPrimary
    property string bgSecondary: colors.bgSecondary
    property string bgSecondaryHover: colors.bgSecondaryHover
    property string bgPrimaryDark: colors.bgPrimaryDark
    property string bgSecondaryDark: colors.bgSecondaryDark
    property string bgGradient1: colors.bgGradient1
    property string bgGradient2: colors.bgGradient2
    property string bgGradient3: colors.bgGradient3

    width: 500
    height: 210

    ColorLoader {
        id: colors
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 0
        color: bgPrimary
        radius: 20
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            systemStats.running = true;
        }
    }

    Process {
        id: systemStats

        property int cpu: 0
        property int ram: 0
        property int temp: 0
        property int gpu: 0

        command: ["sh", "-c", "echo $(top -bn1 | grep 'Cpu(s)' | awk '{print 100 - $8}' | cut -d'.' -f1) " + "$(free | awk '/Mem:/ {printf(\"%.0f\", $3/$2 * 100)}') " + "$(sensors | awk '/Package id 0/ {print $4}' | tr -d '+°C')" + "$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)"]
        running: true

        stdout: SplitParser {
            onRead: function(data) {
                let parts = data.trim().split(" ");
                systemStats.cpu = parseInt(parts[0]);
                systemStats.ram = parseInt(parts[1]);
                systemStats.temp = parseInt(parts[2]);
                systemStats.gpu = parseInt(parts[3]);
            }
        }

    }
 

    Row {
        anchors.fill: parent
        anchors.centerIn: parent
        anchors.margins: 15
        spacing: 10

        Rectangle {
            width: 150
            height: 200
            color: bgSecondary
            radius: 15
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                width: 120
                height: 120
                radius: width / 2
                anchors.horizontalCenter: parent.horizontalCenter
                color: bgSecondaryDark
                anchors.top: parent.top
                anchors.topMargin: 15

                Shape {
                    id: s1

                    width: parent.width + 5
                    height: parent.height + 5
                    anchors.centerIn: parent
                    layer.enabled: true
                    layer.samples: 8

                    ShapePath {
                        id: sp1

                        strokeWidth: 10
                        strokeColor: "#009E60"
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap

                        PathAngleArc {
                            centerX: s1.width / 2
                            centerY: s1.width / 2
                            radiusX: (s1.width - sp1.strokeWidth) / 2
                            radiusY: (s1.width - sp1.strokeWidth) / 2
                            startAngle: -90
                            sweepAngle: systemStats.ram * 3.6

                            Behavior on sweepAngle {
                                NumberAnimation {
                                    duration: 600
                                    easing.type: Easing.InOutQuad
                                }

                            }

                        }

                    }

                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width - 15
                    height: parent.width - 15
                    color: bgSecondary
                    radius: parent.radius

                    Text {
                        text: systemStats.ram + "%"
                        font.pointSize: 35
                        font.bold: false
                        color: bgPrimary
                        anchors.centerIn: parent
                    }

                }

            }

            Rectangle {
                width: 120
                height: 50
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 15
                anchors.horizontalCenter: parent.horizontalCenter
                color: "transparent"

                Text {
                    property real ram: (systemStats.ram / 100) * 16

                    text: ram.toFixed(1) + " / " + "16 GB"
                    font.pointSize: 15
                    font.bold: true
                    color: bgPrimary
                    anchors.centerIn: parent
                }

            }

        }

        Rectangle {
            width: 150
            height: 200
            color: bgSecondary
            radius: 15
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                width: 120
                height: 120
                radius: width / 2
                anchors.horizontalCenter: parent.horizontalCenter
                color: bgSecondaryDark
                anchors.top: parent.top
                anchors.topMargin: 15

                Shape {
                    id: s2

                    width: parent.width + 5
                    height: parent.height + 5
                    anchors.centerIn: parent
                    layer.enabled: true
                    layer.samples: 8

                    ShapePath {
                        id: sp2

                        strokeWidth: 10
                        strokeColor: "#009E60"
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap

                        PathAngleArc {
                            centerX: s2.width / 2
                            centerY: s2.width / 2
                            radiusX: (s2.width - sp2.strokeWidth) / 2
                            radiusY: (s2.width - sp2.strokeWidth) / 2
                            startAngle: -90
                            sweepAngle: systemStats.cpu * 3.6

                            Behavior on sweepAngle {
                                NumberAnimation {
                                    duration: 600
                                    easing.type: Easing.InOutQuad
                                }

                            }

                        }

                    }

                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width - 15
                    height: parent.width - 15
                    color: bgSecondary
                    radius: parent.radius

                    Text {
                        text: systemStats.cpu + "%"
                        font.pointSize: 35
                        font.bold: false
                        color: bgPrimary
                        anchors.centerIn: parent
                    }

                }

            }

            Rectangle {
                width: 120
                height: 50
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 15
                anchors.horizontalCenter: parent.horizontalCenter
                color: "transparent"

                Text {
                    property real ram: (systemStats.ram / 100) * 16

                    text: ram.toFixed(1) + " / " + "16 GB"
                    font.pointSize: 15
                    font.bold: true
                    color: bgPrimary
                    anchors.centerIn: parent
                }

            }

        }

        Rectangle {
            width: 150
            height: 200
            color: bgSecondary
            radius: 15
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                width: 120
                height: 120
                radius: width / 2
                anchors.horizontalCenter: parent.horizontalCenter
                color: bgSecondaryDark
                anchors.top: parent.top
                anchors.topMargin: 15

                Shape {
                    id: s3

                    width: parent.width + 5
                    height: parent.height + 5
                    anchors.centerIn: parent
                    layer.enabled: true
                    layer.samples: 8

                    ShapePath {
                        id: sp3

                        strokeWidth: 10
                        strokeColor: "#009E60"
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap

                        PathAngleArc {
                            centerX: s3.width / 2
                            centerY: s3.width / 2
                            radiusX: (s3.width - sp3.strokeWidth) / 2
                            radiusY: (s3.width - sp3.strokeWidth) / 2
                            startAngle: -90
                            sweepAngle: systemStats.temp * 3.6

                            Behavior on sweepAngle {
                                NumberAnimation {
                                    duration: 600
                                    easing.type: Easing.InOutQuad
                                }

                            }

                        }

                    }

                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width - 15
                    height: parent.width - 15
                    color: bgSecondary
                    radius: parent.radius

                    Text {
                        text: systemStats.temp + "%"
                        font.pointSize: 35
                        font.bold: false
                        color: bgPrimary
                        anchors.centerIn: parent
                    }

                }

            }

            Rectangle {
                width: 120
                height: 50
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 15
                anchors.horizontalCenter: parent.horizontalCenter
                color: "transparent"

                Text {
                    property real ram: (systemStats.ram / 100) * 16

                    text: ram.toFixed(1) + " / " + "16 GB"
                    font.pointSize: 15
                    font.bold: true
                    color: bgPrimary
                    anchors.centerIn: parent
                }

            }

        }

    }

}
