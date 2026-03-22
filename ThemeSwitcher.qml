import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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

    function moveColorFileDark(themeName) {
        var themesPath = "/home/yassine/.config/quickshell/themes";
        var sourcePath = themesPath + "/" + themeName + "/light/colors.json";
        var destPath = themesPath + "/colors.json";
        var kittySourcePath = themesPath + "/" + themeName + "/light/color.conf";
        var kittyDestPath = "/home/yassine/.config/kitty/color.conf";
        var gtk4SourcePath = themesPath + "/" + themeName + "/light/gtk-4.0";
        var gtk4DestPath = "/home/yassine/.config";
        var gtk3SourcePath = themesPath + "/" + themeName + "/light/gtk-3.0";
        var gtk3DestPath = "/home/yassine/.config";
        moveProcess.command = ["/bin/sh", "-c", "cp '" + sourcePath + "' '" + destPath + "' && cp '" + kittySourcePath + "' '" + kittyDestPath + "' && cp -r '" + gtk4SourcePath + "' '" + gtk4DestPath + "' && cp -r '" + gtk3SourcePath + "' '" + gtk3DestPath + "'"];
        moveProcess.running = true;
    }

    function moveColorFileLight(themeName) {
        var themesPath = "/home/yassine/.config/quickshell/themes";
        var sourcePath = themesPath + "/" + themeName + "/dark/colors.json";
        var destPath = themesPath + "/colors.json";
        var kittySourcePath = themesPath + "/" + themeName + "/dark/color.conf";
        var kittyDestPath = "/home/yassine/.config/kitty/color.conf";
        var gtk4SourcePath = themesPath + "/" + themeName + "/dark/gtk-4.0";
        var gtk4DestPath = "/home/yassine/.config";
        var gtk3SourcePath = themesPath + "/" + themeName + "/dark/gtk-3.0";
        var gtk3DestPath = "/home/yassine/.config";
        moveProcess.command = ["/bin/sh", "-c", "cp '" + sourcePath + "' '" + destPath + "' && cp '" + kittySourcePath + "' '" + kittyDestPath + "' && cp -r '" + gtk4SourcePath + "' '" + gtk4DestPath + "' && cp -r '" + gtk3SourcePath + "' '" + gtk3DestPath + "'"];
        moveProcess.running = true;
    }

    width: 500
    height: 250

    ColorLoader {
        id: colors
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 0
        color: bgPrimary
        radius: 20

        Text {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.leftMargin: 12
            text: "Themes"
            color: bgSecondary
            font.pixelSize: 25
            font.bold: true
        }

        Text {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 45
            anchors.leftMargin: 12
            text: "My themes i created theme my self"
            color: bgSecondaryDark
            font.pixelSize: 15
        }

        GridLayout {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 10
            columns: 2

            // Theme 1
            Rectangle {
                width: 240
                height: 50
                color: bgSecondary
                radius: 10

                Rectangle {
                    id: toggleTrack1

                    property bool isOn: false

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 10
                    implicitWidth: 60
                    implicitHeight: 30
                    color: bgPrimary
                    radius: 50
                    border.color: bgSecondary
                    border.width: 0

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            toggleTrack1.isOn = !toggleTrack1.isOn;
                            if (toggleTrack1.isOn)
                                moveColorFileDark("theme1");
                            else
                                moveColorFileLight("theme1");
                        }
                    }

                    Rectangle {
                        id: toggleThumb1

                        anchors.fill: parent
                        anchors.margins: 5
                        anchors.leftMargin: toggleTrack1.isOn ? 5 : 30
                        anchors.rightMargin: toggleTrack1.isOn ? 30 : 5
                        color: bgSecondary
                        radius: 50

                        Text {
                            text: toggleTrack1.isOn ? "" : ""
                            anchors.centerIn: parent
                            font.pixelSize: 15
                            color: bgPrimary
                        }

                        Behavior on anchors.leftMargin {
                            NumberAnimation {
                                duration: toggleTrack1.isOn ? 300 : 100
                                easing.type: Easing.InOutQuad
                            }

                        }

                        Behavior on anchors.rightMargin {
                            NumberAnimation {
                                duration: toggleTrack1.isOn ? 100 : 300
                                easing.type: Easing.InOutQuad
                            }

                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 400
                                easing.type: Easing.InOutQuad
                            }

                        }

                    }

                }

                Row {
                    spacing: 10
                    anchors.fill: parent
                    anchors.margins: 5

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Green"
                        color: bgPrimary
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Item {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 100
                        height: 30

                        Row {
                            anchors.fill: parent
                            spacing: 5

                            Rectangle {
                                width: 25
                                height: 25
                                radius: 5
                                color: "#0E1A14"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 25
                                height: 25
                                radius: 5
                                color: "#1F3A2E"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 25
                                height: 25
                                radius: 5
                                color: "#B7E4C7"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                        }

                    }

                }

            }

            // Theme 2
            Rectangle {
                width: 240
                height: 50
                color: bgSecondary
                radius: 10

                Rectangle {
                    id: toggleTrack2

                    property bool isOn: false

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 10
                    implicitWidth: 60
                    implicitHeight: 30
                    color: bgPrimary
                    radius: 50
                    border.color: bgSecondary
                    border.width: 0

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            toggleTrack2.isOn = !toggleTrack2.isOn;
                            if (toggleTrack2.isOn)
                                moveColorFileDark("theme2");
                            else
                                moveColorFileLight("theme2");
                        }
                    }

                    Rectangle {
                        id: toggleThumb2

                        anchors.fill: parent
                        anchors.margins: 5
                        anchors.leftMargin: toggleTrack2.isOn ? 5 : 30
                        anchors.rightMargin: toggleTrack2.isOn ? 30 : 5
                        color: bgSecondary
                        radius: 50

                        Behavior on anchors.leftMargin {
                            NumberAnimation {
                                duration: toggleTrack2.isOn ? 300 : 100
                                easing.type: Easing.InOutQuad
                            }

                        }

                        Behavior on anchors.rightMargin {
                            NumberAnimation {
                                duration: toggleTrack2.isOn ? 100 : 300
                                easing.type: Easing.InOutQuad
                            }

                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 400
                                easing.type: Easing.InOutQuad
                            }

                        }

                    }

                }

                Row {
                    spacing: 10
                    anchors.fill: parent
                    anchors.margins: 5

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Purpel"
                        color: bgPrimary
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Item {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 100
                        height: 30

                        Row {
                            anchors.fill: parent
                            spacing: 5

                            Rectangle {
                                width: 25
                                height: 25
                                radius: 5
                                color: "#1D1433"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 25
                                height: 25
                                radius: 5
                                color: "#3D2860"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 25
                                height: 25
                                radius: 5
                                color: "#D2C7E5"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                        }

                    }

                }

            }

            // Theme 3
            Rectangle {
                width: 240
                height: 50
                color: bgSecondary
                radius: 10

                Rectangle {
                    id: toggleTrack3

                    property bool isOn: false

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 10
                    implicitWidth: 60
                    implicitHeight: 30
                    color: bgPrimary
                    radius: 50
                    border.color: bgSecondary
                    border.width: 0

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            toggleTrack3.isOn = !toggleTrack3.isOn;
                            if (toggleTrack3.isOn)
                                moveColorFileDark("theme3");
                            else
                                moveColorFileLight("theme3");
                        }
                    }

                    Rectangle {
                        id: toggleThumb3

                        anchors.fill: parent
                        anchors.margins: 5
                        anchors.leftMargin: toggleTrack3.isOn ? 5 : 30
                        anchors.rightMargin: toggleTrack3.isOn ? 30 : 5
                        color: bgSecondary
                        radius: 50

                        Behavior on anchors.leftMargin {
                            NumberAnimation {
                                duration: toggleTrack3.isOn ? 300 : 100
                                easing.type: Easing.InOutQuad
                            }

                        }

                        Behavior on anchors.rightMargin {
                            NumberAnimation {
                                duration: toggleTrack3.isOn ? 100 : 300
                                easing.type: Easing.InOutQuad
                            }

                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 400
                                easing.type: Easing.InOutQuad
                            }

                        }

                    }

                }

                Row {
                    spacing: 10
                    anchors.fill: parent
                    anchors.margins: 5

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Blue"
                        color: bgPrimary
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Item {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 100
                        height: 30

                        Row {
                            anchors.fill: parent
                            spacing: 5

                            Rectangle {
                                width: 25
                                height: 25
                                radius: 5
                                color: "#131934"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 25
                                height: 25
                                radius: 5
                                color: "#1A2045"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 25
                                height: 25
                                radius: 5
                                color: "#5D6E96"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                        }

                    }

                }

            }

            // Theme 4
            Rectangle {
                width: 240
                height: 50
                color: bgSecondary
                radius: 10

                Rectangle {
                    id: toggleTrack4

                    property bool isOn: false

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 10
                    implicitWidth: 60
                    implicitHeight: 30
                    color: bgPrimary
                    radius: 50
                    border.color: bgSecondary
                    border.width: 0

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            toggleTrack4.isOn = !toggleTrack4.isOn;
                            if (toggleTrack4.isOn)
                                moveColorFileDark("theme3");
                            else
                                moveColorFileLight("theme3");
                        }
                    }

                    Rectangle {
                        id: toggleThumb4

                        anchors.fill: parent
                        anchors.margins: 5
                        anchors.leftMargin: toggleTrack4.isOn ? 5 : 30
                        anchors.rightMargin: toggleTrack4.isOn ? 30 : 5
                        color: bgSecondary
                        radius: 50

                        Behavior on anchors.leftMargin {
                            NumberAnimation {
                                duration: toggleTrack4.isOn ? 300 : 100
                                easing.type: Easing.InOutQuad
                            }

                        }

                        Behavior on anchors.rightMargin {
                            NumberAnimation {
                                duration: toggleTrack4.isOn ? 100 : 300
                                easing.type: Easing.InOutQuad
                            }

                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 400
                                easing.type: Easing.InOutQuad
                            }

                        }

                    }

                }

                Row {
                    spacing: 10
                    anchors.fill: parent
                    anchors.margins: 5

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Green"
                        color: bgPrimary
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Item {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 100
                        height: 30

                        Row {
                            anchors.fill: parent
                            spacing: 5

                            Rectangle {
                                width: 25
                                height: 25
                                radius: 5
                                color: "#0E1A14"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 25
                                height: 25
                                radius: 5
                                color: "#1F3A2E"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 25
                                height: 25
                                radius: 5
                                color: "#95D5B2"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                        }

                    }

                }

            }

            // Theme 5
            Rectangle {
                width: 240
                height: 50
                color: bgSecondary
                radius: 10

                Rectangle {
                    id: toggleTrack5

                    property bool isOn: false

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 10
                    implicitWidth: 60
                    implicitHeight: 30
                    color: bgPrimary
                    radius: 50
                    border.color: bgSecondary
                    border.width: 0

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            toggleTrack5.isOn = !toggleTrack5.isOn;
                            if (toggleTrack5.isOn)
                                moveColorFileDark("theme1");
                            else
                                moveColorFileLight("theme1");
                        }
                    }

                    Rectangle {
                        id: toggleThumb5

                        anchors.fill: parent
                        anchors.margins: 5
                        anchors.leftMargin: toggleTrack5.isOn ? 5 : 30
                        anchors.rightMargin: toggleTrack5.isOn ? 30 : 5
                        color: bgSecondary
                        radius: 50

                        Behavior on anchors.leftMargin {
                            NumberAnimation {
                                duration: toggleTrack5.isOn ? 300 : 100
                                easing.type: Easing.InOutQuad
                            }

                        }

                        Behavior on anchors.rightMargin {
                            NumberAnimation {
                                duration: toggleTrack5.isOn ? 100 : 300
                                easing.type: Easing.InOutQuad
                            }

                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 400
                                easing.type: Easing.InOutQuad
                            }

                        }

                    }

                }

                Row {
                    spacing: 10
                    anchors.fill: parent
                    anchors.margins: 5

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Green"
                        color: bgPrimary
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Item {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 100
                        height: 30

                        Row {
                            anchors.fill: parent
                            spacing: 5

                            Rectangle {
                                width: 25
                                height: 25
                                radius: 5
                                color: "#0E1A14"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 25
                                height: 25
                                radius: 5
                                color: "#1F3A2E"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 25
                                height: 25
                                radius: 5
                                color: "#95D5B2"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                        }

                    }

                }

            }

            // Theme 6
            Rectangle {
                width: 240
                height: 50
                color: bgSecondary
                radius: 10

                Rectangle {
                    id: toggleTrack6

                    property bool isOn: false

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 10
                    implicitWidth: 60
                    implicitHeight: 30
                    color: bgPrimary
                    radius: 50
                    border.color: bgSecondary
                    border.width: 0

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            toggleTrack6.isOn = !toggleTrack6.isOn;
                            if (toggleTrack6.isOn)
                                moveColorFileDark("theme2");
                            else
                                moveColorFileLight("theme2");
                        }
                    }

                    Rectangle {
                        id: toggleThumb6

                        anchors.fill: parent
                        anchors.margins: 5
                        anchors.leftMargin: toggleTrack6.isOn ? 5 : 30
                        anchors.rightMargin: toggleTrack6.isOn ? 30 : 5
                        color: bgSecondary
                        radius: 50

                        Behavior on anchors.leftMargin {
                            NumberAnimation {
                                duration: toggleTrack6.isOn ? 300 : 100
                                easing.type: Easing.InOutQuad
                            }

                        }

                        Behavior on anchors.rightMargin {
                            NumberAnimation {
                                duration: toggleTrack6.isOn ? 100 : 300
                                easing.type: Easing.InOutQuad
                            }

                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 400
                                easing.type: Easing.InOutQuad
                            }

                        }

                    }

                }

                Row {
                    spacing: 10
                    anchors.fill: parent
                    anchors.margins: 5

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Green"
                        color: bgPrimary
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Item {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 100
                        height: 30

                        Row {
                            anchors.fill: parent
                            spacing: 5

                            Rectangle {
                                width: 25
                                height: 25
                                radius: 5
                                color: "#0E1A14"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 25
                                height: 25
                                radius: 5
                                color: "#1F3A2E"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 25
                                height: 25
                                radius: 5
                                color: "#95D5B2"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                        }

                    }

                }

            }

        }

    }

    Process {
        id: moveProcess

        running: false
    }

}
