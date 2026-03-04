import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

FloatingWindow{
    id: wallpaperWindow

    property string wallpaperDir: "/home/yassine/Pictures/Wallpapers"
    property var wallpapers: []

    function loadWallpapers() {
        findProcess.running = true;
    }

    function setWallpaper(path) {
        swwwProcess.command = ["swww", "img", path, "--transition-type", "fade", "--transition-duration", "2"];
        swwwProcess.running = true;
    }

    Process {
        id: findProcess
        command: ["sh", "-c", "find /home/yassine/Pictures/Wallpapers -type f \\( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \\)"]
        running: false

        stdout: SplitParser {
            onRead: function(data) {
                if (data.trim().length > 0) {
                    wallpapers.push(data.trim());
                    gridView.model = wallpapers.length;
                }
            }
        }

        onStarted: {
            wallpapers = [];
        }
    }

    Process {
        id: swwwProcess
        running: false
    }

    width: 900
    height: 700

    Component.onCompleted: {
        loadWallpapers();
    }

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20

            // Header
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: "#313244"
                radius: 12

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Rectangle {
                        width: 50
                        height: 50
                        radius: 10
                        color: "#45475a"

                        Text {
                            anchors.centerIn: parent
                            text: "🖼️"
                            font.pixelSize: 28
                        }
                    }

                    ColumnLayout {
                        spacing: 2

                        Text {
                            text: "Wallpaper Switcher"
                            font.pixelSize: 26
                            font.bold: true
                            color: "#cdd6f4"
                        }

                        Text {
                            text: wallpapers.length + " wallpapers available"
                            color: "#a6adc8"
                            font.pixelSize: 13
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Button {
                        text: "🔄 Refresh"
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 40

                        onClicked: wallpaperWindow.loadWallpapers()

                        background: Rectangle {
                            color: parent.pressed ? "#585b70" : parent.hovered ? "#6c7086" : "#45475a"
                            radius: 8
                            border.color: "#585b70"
                            border.width: 1

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#cdd6f4"
                            font.pixelSize: 13
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "✕"
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40

                        onClicked: Qt.quit()

                        background: Rectangle {
                            color: parent.pressed ? "#f38ba8" : parent.hovered ? "#f5c2e7" : "#45475a"
                            radius: 8
                            border.color: parent.hovered ? "#f38ba8" : "#585b70"
                            border.width: 1

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }

                        contentItem: Text {
                            text: parent.text
                            color: parent.parent.hovered ? "#1e1e2e" : "#cdd6f4"
                            font.pixelSize: 18
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            // Grid of wallpapers
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                background: Rectangle {
                    color: "#181825"
                    radius: 12
                    border.color: "#313244"
                    border.width: 1
                }

                GridView {
                    id: gridView
                    cellWidth: 220
                    cellHeight: 220
                    model: 0
                    anchors.margins: 15

                    delegate: Rectangle {
                        property string wallpaperPath: wallpaperWindow.wallpapers[index] || ""
                        property bool isHovered: mouseArea.containsMouse

                        width: 200
                        height: 200
                        color: isHovered ? "#45475a" : "#313244"
                        radius: 12
                        border.color: isHovered ? "#585b70" : "transparent"
                        border.width: 2

                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }

                        Behavior on border.color {
                            ColorAnimation { duration: 200 }
                        }

                        scale: isHovered ? 1.05 : 1.0

                        Behavior on scale {
                            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "#181825"
                                radius: 10
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    source: "file://" + wallpaperPath
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: false
                                    smooth: true
                                }

                                // Overlay on hover
                                Rectangle {
                                    anchors.fill: parent
                                    color: "#1e1e2e"
                                    opacity: parent.parent.parent.isHovered ? 0.3 : 0
                                    radius: 10

                                    Behavior on opacity {
                                        NumberAnimation { duration: 200 }
                                    }
                                }
                            }

                            Text {
                                text: wallpaperPath.split('/').pop()
                                color: isHovered ? "#cdd6f4" : "#a6adc8"
                                font.pixelSize: 12
                                font.bold: isHovered
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter

                                Behavior on color {
                                    ColorAnimation { duration: 200 }
                                }
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                wallpaperWindow.setWallpaper(wallpaperPath);
                            }
                        }
                    }
                }
            }
        }
    }
}