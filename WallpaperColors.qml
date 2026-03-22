import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "services"

Item {
    id: root

    property string activeBackend: "colorthief"
    property var backends: ["wal", "colorthief", "colorz", "haishoku", "scikit-learn", "pillow"]
    property string colorsJsonFilePath: "/home/yassine/.cache/wal/colors.json"
    property string outputJsonFilePath: "/home/yassine/.config/quickshell/themes/colors.json"
    property string bgColor0: "#424049"
    property string bgColor1: "#424049"
    property string bgColor2: "#424049"
    property string bgColor3: "#424049"
    property string bgColor4: "#424049"
    property string bgColor5: "#424049"
    property string bgColor6: "#424049"
    property string bgColor7: "#424049"
    property string bgColor8: "#424049"
    property string currentWallpaper: ""
    property real mode: 0.8
    property color bgColor: Qt.hsla(baseColor.hslHue, Math.min(1, baseColor.hslSaturation * 0.5), mode, baseColor.a)
    property color baseColor: bgColor1
    property color primaryDark: Qt.hsla(baseColor.hslHue, Math.min(1, baseColor.hslSaturation * 0.8), 0.3, baseColor.a)
    property color primary: Qt.hsla(baseColor.hslHue, baseColor.hslSaturation, Math.min(1, baseColor.hslLightness * 0.85), baseColor.a)
    property color gradient3: Qt.hsla(baseColor.hslHue, Math.min(1, baseColor.hslSaturation * 0.8), 0.4, baseColor.a)
    property color gradient2: Qt.hsla(baseColor.hslHue, Math.min(1, baseColor.hslSaturation * 0.75), Math.min(1, baseColor.hslLightness * 1.1), baseColor.a)
    property color gradient1: Qt.hsla(baseColor.hslHue, Math.min(1, baseColor.hslSaturation * 0.9), 0.75, baseColor.a)
    property color secondaryDark: Qt.hsla(baseColor.hslHue, Math.min(1, baseColor.hslSaturation * 1.1), Math.min(1, baseColor.hslLightness * 3), baseColor.a)
    property color secondary: Qt.hsla(baseColor.hslHue, Math.min(1, baseColor.hslSaturation * 0.95), Math.min(1, baseColor.hslLightness * 3), baseColor.a)
    property color secondaryHover: Qt.hsla(baseColor.hslHue, Math.min(1, baseColor.hslSaturation * 0.9), 0.9, baseColor.a)

    function colorToHex(color) {
        var r = Math.round(color.r * 255);
        var g = Math.round(color.g * 255);
        var b = Math.round(color.b * 255);
        return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1).toUpperCase();
    }

    function writeColorsJson() {
        var jsonData = {
            "dark": {
                "notch": "#000000",
                "bg": colorToHex(bgColor),
                "Primary": colorToHex(primary),
                "PrimaryDark": colorToHex(primaryDark),
                "SecondaryHover": colorToHex(secondaryHover),
                "SecondaryDark": colorToHex(secondaryDark),
                "Secondary": colorToHex(secondary),
                "Gradient1": colorToHex(gradient1),
                "Gradient2": colorToHex(gradient2),
                "Gradient3": colorToHex(gradient3)
            }
        };
        var jsonString = JSON.stringify(jsonData, null, 4);
        writeProcess.command = ["sh", "-c", "echo '" + jsonString + "' > " + outputJsonFilePath];
        writeProcess.running = true;
    }

    function reloadColorsFromDisk() {
        colorReader.path = "";
        reloadTimer.start();
    }

    function loadColors() {
        walProcess.running = true;
        matugenProcess.running = true;
    }

    width: 472
    height: 150

    Timer {
        id: reloadTimer

        interval: 50
        running: false
        repeat: false
        onTriggered: {
            colorReader.path = root.colorsJsonFilePath;
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: "transparent"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 0
                    spacing: 0

                    Text {
                        text: "Choose a color"
                        color: secondary
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Row {
                        spacing: 5

                        Repeater {
                            model: [bgColor1, bgColor2, bgColor3, bgColor4, bgColor5, bgColor6, bgColor7]

                            Rectangle {
                                width: 25
                                height: 25
                                color: modelData
                                radius: 5
                                border.width: root.baseColor === modelData ? 3 : 1
                                border.color: root.baseColor === modelData ? primary : Qt.rgba(1, 1, 1, 0.2)

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.baseColor = modelData;
                                        colorWriteDelay.start();
                                    }
                                }

                            }

                        }

                    }

                }

            }

            Rectangle {
                height: 60
                width: 450
                color: "transparent"

                Timer {
                    id: colorWriteDelay

                    interval: 50
                    running: false
                    repeat: false
                    onTriggered: root.writeColorsJson()
                }

                GridLayout {
                    columns: 3
                    rowSpacing: 5
                    columnSpacing: 5
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 5

                    Repeater {
                        model: root.backends

                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 30
                            radius: activeBackend === modelData ? 50 : 10
                            color: activeBackend === modelData ? secondaryHover : secondary

                            Text {
                                text: modelData
                                color: primary
                                anchors.centerIn: parent
                                font.pixelSize: 13
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.activeBackend = modelData;
                                    root.loadColors();
                                }
                            }

                            Behavior on Layout.preferredWidth {
                                NumberAnimation {
                                    duration: 50
                                    easing.type: Easing.OutBack
                                }

                            }

                        }

                    }

                }

                Rectangle {
                    width: 30
                    height: 30
                    radius: 50
                    color: root.mode === 0.09 ? secondaryHover : secondary
                    anchors.left: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.mode = (root.mode === 0.8) ? 0.09 : 0.8;
                            // root.darkWriteColorsJson()
                            colorWriteDelay.start();
                        }
                    }

                    Text {
                        text: root.mode === 0.09 ? "Dark" : "Light"
                        color: primary
                        anchors.centerIn: parent
                        font.pixelSize: 10
                        font.bold: true
                    }

                    Behavior on Layout.preferredWidth {
                        NumberAnimation {
                            duration: 50
                            easing.type: Easing.OutBack
                        }

                    }

                }

                Rectangle {
                    width: 160
                    height: 70
                    color: Qt.hsla(primaryDark.hslHue, Math.min(1, primaryDark.hslSaturation * 1), 0.5, primaryDark.a)
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    radius: 8

                    GridLayout {
                        anchors.centerIn: parent
                        columns: 5
                        rowSpacing: 5
                        columnSpacing: 5

                        Rectangle {
                            Layout.preferredWidth: 25
                            Layout.preferredHeight: 25
                            color: bgColor
                            radius: 5
                        }

                        Rectangle {
                            Layout.preferredWidth: 25
                            Layout.preferredHeight: 25
                            color: primaryDark
                            radius: 5
                        }

                        Rectangle {
                            Layout.preferredWidth: 25
                            Layout.preferredHeight: 25
                            color: primary
                            radius: 5
                        }

                        Rectangle {
                            Layout.preferredWidth: 25
                            Layout.preferredHeight: 25
                            color: secondary
                            radius: 5
                        }

                        Rectangle {
                            Layout.preferredWidth: 25
                            Layout.preferredHeight: 25
                            color: secondaryDark
                            radius: 5
                        }

                        Rectangle {
                            Layout.preferredWidth: 25
                            Layout.preferredHeight: 25
                            color: gradient1
                            radius: 5
                        }

                        Rectangle {
                            Layout.preferredWidth: 25
                            Layout.preferredHeight: 25
                            color: gradient2
                            radius: 5
                        }

                        Rectangle {
                            Layout.preferredWidth: 25
                            Layout.preferredHeight: 25
                            color: gradient3
                            radius: 5
                        }

                        Rectangle {
                            Layout.preferredWidth: 25
                            Layout.preferredHeight: 25
                            color: secondaryHover
                            radius: 5
                        }

                    }

                }

            }

        }

    }

    // Runs pywal with the selected backend
    Process {
        id: walProcess

        command: ["wal", "-i", root.currentWallpaper, "-n", "--backend", activeBackend, "--saturate", "0"]
        running: false
        onExited: (exitCode, exitStatus) => {
            walProcess.running = false;
            if (exitCode === 0)
                root.reloadColorsFromDisk();

        }
    }

    // Runs matugen in parallel with wal
    Process {
        id: matugenProcess

        command: ["matugen", "image", root.currentWallpaper, "--source-color-index", "0"]
        running: false
        onExited: (exitCode, exitStatus) => {
            console.log("matugen exited:", exitCode === 0 ? "success" : "failed");
            matugenProcess.running = false;
        }
    }

    // Writes the derived theme JSON to the output path
    Process {
        id: writeProcess

        running: false
        onExited: (exitCode, exitStatus) => {
            console.log("JSON file written:", exitCode === 0 ? "success" : "failed");
            writeProcess.running = false;
        }
    }

    // Reads wal's colors.json and updates all bgColor properties
    FileView {
        id: colorReader

        path: ""
        onLoaded: {
            try {
                var data = JSON.parse(text());
                if (data.colors) {
                    root.bgColor0 = data.colors.color0;
                    root.bgColor1 = data.colors.color1;
                    root.bgColor2 = data.colors.color2;
                    root.bgColor3 = data.colors.color3;
                    root.bgColor4 = data.colors.color4;
                    root.bgColor5 = data.colors.color5;
                    root.bgColor6 = data.colors.color6;
                    root.bgColor7 = data.colors.color7;
                    root.bgColor8 = data.colors.color8;
                    colorWriteDelay.start();
                }
            } catch (e) {
                console.log("Error parsing colors:", e);
            }
        }
    }

}
