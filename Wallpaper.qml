import Qt5Compat.GraphicalEffects
import QtMultimedia
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import "Widgets"
import "services"

Item {
    id: wallpaperWindow

    property string bgColor: colors.bgColor
    property string bgPrimary: colors.bgPrimary
    property string bgSecondary: colors.bgSecondary
    property string bgSecondaryHover: colors.bgSecondaryHover
    property string bgPrimaryDark: colors.bgPrimaryDark
    property string bgSecondaryDark: colors.bgSecondaryDark
    property string bgGradient1: colors.bgGradient1
    property string bgGradient2: colors.bgGradient2
    property string bgGradient3: colors.bgGradient3
    property string wallpaperDir: "/home/yassine/Pictures/Wallpapers"
    property string current: wColors.currentWallpaper
    property var wallpapers: []
    property int currentIndex: 0
    property bool isopenn: true
    property bool useVideo: false // Toggle between video and image
    property bool parallaxEnabled: true // Toggle parallax effect
    property string videoSource: "file:///home/yassine/.config/quickshell/gg2.mp4"

    function loadWallpapers() {
        findProcess.running = true;
    }

    function setWallpaper(path) {
        if (wallpaperWindow.useVideo) {
            // Set video source
            wallpaperWindow.videoSource = "file://" + path;
            player.play();
        } else {
            // Set image wallpaper
            swwwProcess.command = ["swww", "img", path, "--transition-type", "wipe", "--transition-duration", "0.6"];
            swwwProcess.running = true;
            wColors.currentWallpaper = path;
        }
    }

    function nextWallpaper() {
        if (currentIndex < wallpapers.length - 1) {
            currentIndex++;
            listView.currentIndex = currentIndex;
        }
    }

    function previousWallpaper() {
        if (currentIndex > 0) {
            currentIndex--;
            listView.currentIndex = currentIndex;
        }
    }

    width: 500
    height: 380
    Component.onCompleted: {
        loadWallpapers();
    }

    Background {
        id: background

        visible: false
    }

    ColorLoader {
        id: colors
    }

    Process {
        id: findProcess

        command: ["sh", "-c", "find " + wallpaperWindow.wallpaperDir + " -type f \\( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' -o -iname '*.mp4' -o -iname '*.mkv' -o -iname '*.webm' \\)"]
        running: false
        onStarted: {
            wallpapers = [];
        }

        stdout: SplitParser {
            onRead: function(data) {
                if (data.trim().length > 0) {
                    wallpapers.push(data.trim());
                    listView.model = wallpapers.length;
                }
            }
        }

    }

    Process {
        id: swwwProcess

        running: false
    }

    PanelWindow {
        id: bg

        property string img: wColors.currentWallpaper
        property real shift: 0
        property int currentWorkspace: 1
        property real shiftAmount: -10

        visible: true
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "depth-wallpaper-below"
        WlrLayershell.exclusiveZone: -1
        Component.onCompleted: {
            if (Hyprland.focusedMonitor && Hyprland.focusedMonitor.activeWorkspace) {
                bg.currentWorkspace = Hyprland.focusedMonitor.activeWorkspace.id;
                bg.shift = wallpaperWindow.parallaxEnabled ? (bg.currentWorkspace - 1) * bg.shiftAmount : 0;
            }
        }

        Connections {
            function onActiveWorkspaceChanged() {
                if (Hyprland.focusedMonitor.activeWorkspace) {
                    bg.currentWorkspace = Hyprland.focusedMonitor.activeWorkspace.id;
                    bg.shift = wallpaperWindow.parallaxEnabled ? (bg.currentWorkspace - 1) * bg.shiftAmount : 0;
                }
            }

            target: Hyprland.focusedMonitor
        }

        anchors {
            left: true
            right: true
            top: true
            bottom: true
        }

        // Image Background
        Image {
            id: image

            visible: !wallpaperWindow.useVideo
            source: wColors.currentWallpaper
            width: parent.width
            height: parent.height
            scale: 1.1
            fillMode: Image.PreserveAspectCrop
            enabled: false
            x: (wallpaperWindow.isopenn ? 50 : 0) + bg.shift
            y: -20

            Behavior on x {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic
                }

            }

        }

        // Video Background
        MediaPlayer {
            id: player

            source: wallpaperWindow.videoSource
            videoOutput: videoOut
            loops: MediaPlayer.Infinite
            Component.onCompleted: {
                if (wallpaperWindow.useVideo)
                    player.play();

            }
            onPlaybackStateChanged: {
                if (playbackState === MediaPlayer.StoppedState && wallpaperWindow.useVideo)
                    player.play();

            }

            audioOutput: AudioOutput {
                muted: true
            }

        }

        VideoOutput {
            id: videoOut

            visible: wallpaperWindow.useVideo
            width: parent.width
            height: parent.height
            fillMode: VideoOutput.PreserveAspectCrop
            scale: 1.1
            x: (wallpaperWindow.isopenn ? 50 : 0) + bg.shift
            y: -20

            Behavior on x {
                NumberAnimation {
                    duration: 450
                    easing.type: Easing.OutCubic
                }

            }

        }

    }

    Rectangle {
        width: 500
        height: 380
        radius: 20
        anchors.centerIn: parent
        color: bgColor

        Rectangle {
            anchors.fill: parent
            radius: 20
            color: bgPrimary
            anchors.margins: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 0

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60

                    Column {
                        anchors.fill: parent
                        spacing: 2

                        Text {
                            text: "Wallpapers"
                            color: bgSecondary
                            font.pixelSize: 25
                            font.bold: true
                        }

                        Text {
                            text: "Auto generated themes from the wallpaper"
                            color: bgSecondaryDark
                            font.pixelSize: 15
                        }

                    }

                    Row {
                        anchors.right: parent.right
                        spacing: 8

                        // Video/Image Toggle Button
                        Rectangle {
                            color: wallpaperWindow.useVideo ? bgSecondaryHover : bgSecondary
                            width: 100
                            height: 40
                            radius: 10

                            Text {
                                text: wallpaperWindow.useVideo ? "Video" : "Image"
                                anchors.centerIn: parent
                                color: bgPrimary
                                font.pixelSize: 15
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    wallpaperWindow.useVideo = !wallpaperWindow.useVideo;
                                    if (wallpaperWindow.useVideo)
                                        wallpaperWindow.wallpaperDir = "/home/yassine/Pictures/WallpapersVideo";
                                    else
                                        wallpaperWindow.wallpaperDir = "/home/yassine/Pictures/Wallpapers";
                                    wallpaperWindow.currentIndex = 0;
                                    wallpaperWindow.loadWallpapers();
                                }
                            }

                        }

                        // Parallax Effect Button
                        Rectangle {
                            color: wallpaperWindow.parallaxEnabled ? bgSecondaryHover : bgSecondary
                            width: 130
                            height: 40
                            radius: wallpaperWindow.parallaxEnabled ? 20 : 10

                            Text {
                                text: "Parallax effect"
                                anchors.centerIn: parent
                                color: bgPrimary
                                font.pixelSize: 15
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    wallpaperWindow.parallaxEnabled = !wallpaperWindow.parallaxEnabled;
                                    if (!wallpaperWindow.parallaxEnabled)
                                        bg.shift = 0;
                                    else if (Hyprland.focusedMonitor && Hyprland.focusedMonitor.activeWorkspace)
                                        bg.shift = (bg.currentWorkspace - 1) * bg.shiftAmount;
                                }
                            }

                        }

                    }

                }

                // Wallpaper Display Section
                Rectangle {
                    Layout.fillWidth: true
                    height: 150
                    color: "transparent"
                    radius: 14

                    Rectangle {
                        anchors.fill: parent
                        color: bgPrimary
                        radius: 14
                        clip: true
                        layer.enabled: true

                        ListView {
                            id: listView

                            anchors.fill: parent
                            anchors.margins: 4
                            orientation: ListView.Horizontal
                            spacing: 10
                            model: 0
                            snapMode: ListView.SnapOneItem
                            highlightRangeMode: ListView.StrictlyEnforceRange
                            preferredHighlightBegin: width / 2 - 105
                            preferredHighlightEnd: width / 2 + 105
                            interactive: false
                            highlightFollowsCurrentItem: true
                            highlightMoveDuration: 350
                            clip: true

                            displaced: Transition {
                                NumberAnimation {
                                    properties: "x,y"
                                    duration: 350
                                    easing.type: Easing.OutCubic
                                }

                            }

                            Behavior on contentX {
                                SmoothedAnimation {
                                    duration: 350
                                    velocity: -1
                                    easing.type: Easing.OutCubic
                                }

                            }

                            delegate: Rectangle {
                                property string wallpaperPath: wallpaperWindow.wallpapers[index] || ""
                                property bool isHovered: mouseArea.containsMouse
                                property bool isCurrent: index === wallpaperWindow.currentIndex

                                width: 240
                                height: listView.height - 8
                                anchors.verticalCenter: parent.verticalCenter
                                color: "transparent"
                                radius: 12
                                opacity: isCurrent ? 1 : 0.6
                                scale: isHovered ? 0.98 : (isCurrent ? 0.95 : 0.8)
                                layer.enabled: true

                                Rectangle {
                                    id: cover

                                    anchors.fill: parent
                                    color: "#2A1B42"
                                    radius: 8
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        source: "file://" + wallpaperPath
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: false
                                        smooth: true
                                        clip: true
                                        layer.enabled: true

                                        layer.effect: OpacityMask {

                                            maskSource: Rectangle {
                                                width: cover.width
                                                height: cover.height
                                                radius: 8
                                            }

                                        }

                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: "transparent"
                                        radius: 8

                                        gradient: Gradient {
                                            GradientStop {
                                                position: 0.7
                                                color: "transparent"
                                            }

                                            GradientStop {
                                                position: 1
                                                color: "#BB000000"
                                            }

                                        }

                                    }

                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        height: 28
                                        color: "transparent"

                                        Text {
                                            anchors.centerIn: parent
                                            anchors.margins: 8
                                            text: wallpaperPath.split('/').pop()
                                            color: isCurrent ? "#F0E6FF" : "#C4B3E0"
                                            font.pixelSize: 12
                                            font.bold: true
                                            elide: Text.ElideMiddle
                                            width: parent.width - 16
                                            horizontalAlignment: Text.AlignHCenter
                                            anchors.fill: parent

                                            Behavior on color {
                                                ColorAnimation {
                                                    duration: 200
                                                }

                                            }

                                        }

                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: "#FFFFFF"
                                        opacity: isHovered ? 0.08 : 0
                                        radius: 8

                                        Behavior on opacity {
                                            NumberAnimation {
                                                duration: 150
                                            }

                                        }

                                    }

                                }

                                MouseArea {
                                    id: mouseArea

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        Quickshell.execDetached(["notify-send","Wallpaper changed"])
                                        console.log("hi")
                                        wallpaperWindow.currentIndex = index;
                                        wallpaperWindow.setWallpaper(wallpaperPath);
                                        if (!wallpaperWindow.useVideo)
                                            wColors.loadColors();

                                    }
                                }

                                Process {
                                    id: findProcess

                                    command: ["sh", "-c", "find " + wallpaperWindow.wallpaperDir + " -type f \\( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' -o -iname '*.mp4' -o -iname '*.mkv' -o -iname '*.webm' \\)"]
                                    running: false
                                    onStarted: {
                                        wallpapers = [];
                                    }

                                    stdout: SplitParser {
                                        onRead: function(data) {
                                            if (data.trim().length > 0) {
                                                wallpapers.push(data.trim());
                                                listView.model = wallpapers.length;
                                            }
                                        }
                                    }

                                }

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 200
                                    }

                                }

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 200
                                        easing.type: Easing.OutCubic
                                    }

                                }

                            }

                        }

                        // Left shadow gradient
                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: 70
                            z: 5
                            radius: 14

                            gradient: Gradient {
                                orientation: Gradient.Horizontal

                                GradientStop {
                                    position: 0
                                    color: bgPrimary

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                            easing.type: Easing.InOutQuad
                                        }

                                    }

                                }

                                GradientStop {
                                    position: 1
                                    color: "#003D2860"

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                            easing.type: Easing.InOutQuad
                                        }

                                    }

                                }

                            }

                        }

                        // Left Arrow
                        Rectangle {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 8
                            height: parent.height - 16
                            width: 40
                            color: leftMouseArea.containsMouse ? bgSecondaryHover : bgSecondary
                            radius: 10
                            z: 10

                            Text {
                                anchors.centerIn: parent
                                text: "‹"
                                color: bgPrimary
                                font.pixelSize: 50
                                font.weight: Font.Bold
                            }

                            MouseArea {
                                id: leftMouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: currentIndex > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    if (currentIndex > 0)
                                        wallpaperWindow.previousWallpaper();

                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }

                            }

                        }

                        // Right shadow gradient
                        Rectangle {
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: 70
                            z: 5
                            radius: 14

                            gradient: Gradient {
                                orientation: Gradient.Horizontal

                                GradientStop {
                                    position: 0
                                    color: "#003D2860"

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                            easing.type: Easing.InOutQuad
                                        }

                                    }

                                }

                                GradientStop {
                                    position: 1
                                    color: bgPrimary

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                            easing.type: Easing.InOutQuad
                                        }

                                    }

                                }

                            }

                        }

                        // Right Arrow
                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.rightMargin: 8
                            height: parent.height - 16
                            width: 40
                            color: rightMouseArea.containsMouse ? bgSecondaryHover : bgSecondary
                            radius: 10
                            z: 10

                            Text {
                                anchors.centerIn: parent
                                text: "›"
                                color: bgPrimary
                                font.pixelSize: 50
                                font.weight: Font.Bold
                            }

                            MouseArea {
                                id: rightMouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: currentIndex < wallpapers.length - 1 ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    if (currentIndex < wallpapers.length - 1)
                                        wallpaperWindow.nextWallpaper();

                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
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

                }

                // Bottom Section - WallpaperColors
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 150
                    color: "transparent"

                    WallpaperColors {
                        id: wColors
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

    }

}
