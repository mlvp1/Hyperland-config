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
    // ── Background / Wallpaper services ──────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════
    //  Main UI Panel
    // ══════════════════════════════════════════════════════════════════════════

    id: wallpaperWindow

    // ── Color Loader ─────────────────────────────────────────────────────────
    property string bgColor: colors.bgColor
    property string bgPrimary: colors.bgPrimary
    property string bgSecondary: colors.bgSecondary
    property string bgSecondaryHover: colors.bgSecondaryHover
    property string bgPrimaryDark: colors.bgPrimaryDark
    property string bgSecondaryDark: colors.bgSecondaryDark
    property string bgGradient1: colors.bgGradient1
    property string bgGradient2: colors.bgGradient2
    property string bgGradient3: colors.bgGradient3
    // ── Wallpaper State ───────────────────────────────────────────────────────
    property string wallpaperDir: "/home/yassine/Pictures/Wallpapers"
    property var wallpapers: []
    property int currentIndex: 0
    property bool isopenn: true
    property bool useVideo: false
    property bool parallaxEnabled: true
    property string videoSource: "file:///home/yassine/.config/quickshell/gg2.mp4"
    // ── WallpaperColors State (merged from WallpaperColors.qml) ──────────────
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
    property real colorMode: 0.8
    property color baseColor: bgColor1
    property color derivedBg: Qt.hsla(baseColor.hslHue, Math.min(1, baseColor.hslSaturation * 0.5), colorMode, baseColor.a)
    property color primaryDark: Qt.hsla(baseColor.hslHue, Math.min(1, baseColor.hslSaturation * 0.8), 0.3, baseColor.a)
    property color primary: Qt.hsla(baseColor.hslHue, baseColor.hslSaturation, Math.min(1, baseColor.hslLightness * 0.85), baseColor.a)
    property color gradient3c: Qt.hsla(baseColor.hslHue, Math.min(1, baseColor.hslSaturation * 0.8), 0.4, baseColor.a)
    property color gradient2c: Qt.hsla(baseColor.hslHue, Math.min(1, baseColor.hslSaturation * 0.75), Math.min(1, baseColor.hslLightness * 1.1), baseColor.a)
    property color gradient1c: Qt.hsla(baseColor.hslHue, Math.min(1, baseColor.hslSaturation * 0.9), 0.75, baseColor.a)
    property color secondaryDark: Qt.hsla(baseColor.hslHue, Math.min(1, baseColor.hslSaturation * 1.1), Math.min(1, baseColor.hslLightness * 3), baseColor.a)
    property color secondary: Qt.hsla(baseColor.hslHue, Math.min(1, baseColor.hslSaturation * 0.95), Math.min(1, baseColor.hslLightness * 3), baseColor.a)
    property color secondaryHover: Qt.hsla(baseColor.hslHue, Math.min(1, baseColor.hslSaturation * 0.9), 0.9, baseColor.a)

    // ── Helpers ───────────────────────────────────────────────────────────────
    function loadWallpapers() {
        findProcess.running = true;
    }

    function setWallpaper(path) {
        if (wallpaperWindow.useVideo) {
            wallpaperWindow.videoSource = "file://" + path;
            player.play();
        } else {
            swwwProcess.command = ["swww", "img", path, "--transition-type", "wipe", "--transition-duration", "0.6"];
            swwwProcess.running = true;
            wallpaperWindow.currentWallpaper = path;
        }
    }

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
                "bg": colorToHex(derivedBg),
                "Primary": colorToHex(primary),
                "PrimaryDark": colorToHex(primaryDark),
                "SecondaryHover": colorToHex(secondaryHover),
                "SecondaryDark": colorToHex(secondaryDark),
                "Secondary": colorToHex(secondary),
                "Gradient1": colorToHex(gradient1c),
                "Gradient2": colorToHex(gradient2c),
                "Gradient3": colorToHex(gradient3c)
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

    width: 1420
    height: 800
    Component.onCompleted: {
        loadWallpapers();
    }

    ColorLoader {
        id: colors
    }

    // ── Processes ─────────────────────────────────────────────────────────────
    Process {
        id: findProcess

        command: ["sh", "-c", "find " + wallpaperWindow.wallpaperDir + " -type f \\( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg'" + " -o -iname '*.mp4' -o -iname '*.mkv' -o -iname '*.webm' \\)"]
        running: false
        onStarted: {
            wallpaperWindow.wallpapers = [];
        }

        stdout: SplitParser {
            onRead: function(data) {
                if (data.trim().length > 0) {
                    wallpaperWindow.wallpapers.push(data.trim());
                    gridView.model = wallpaperWindow.wallpapers.length;
                }
            }
        }

    }

    Process {
        id: swwwProcess

        running: false
    }

    Process {
        id: walProcess

        command: ["wal", "-i", wallpaperWindow.currentWallpaper, "-n", "--backend", wallpaperWindow.activeBackend, "--saturate", "0"]
        running: false
        onExited: (exitCode, exitStatus) => {
            walProcess.running = false;
            if (exitCode === 0)
                wallpaperWindow.reloadColorsFromDisk();

        }
    }

    Process {
        id: matugenProcess

        command: ["matugen", "image", wallpaperWindow.currentWallpaper]
        running: false
        onExited: (exitCode, exitStatus) => {
            matugenProcess.running = false;
        }
    }

    Process {
        id: writeProcess

        running: false
        onExited: (exitCode, exitStatus) => {
            writeProcess.running = false;
        }
    }

    FileView {
        id: colorReader

        path: ""
        onLoaded: {
            try {
                var data = JSON.parse(text());
                if (data.colors) {
                    wallpaperWindow.bgColor0 = data.colors.color0;
                    wallpaperWindow.bgColor1 = data.colors.color1;
                    wallpaperWindow.bgColor2 = data.colors.color2;
                    wallpaperWindow.bgColor3 = data.colors.color3;
                    wallpaperWindow.bgColor4 = data.colors.color4;
                    wallpaperWindow.bgColor5 = data.colors.color5;
                    wallpaperWindow.bgColor6 = data.colors.color6;
                    wallpaperWindow.bgColor7 = data.colors.color7;
                    wallpaperWindow.bgColor8 = data.colors.color8;
                    colorWriteDelay.start();
                }
            } catch (e) {
                console.log("Error parsing colors:", e);
            }
        }
    }

    Timer {
        id: reloadTimer

        interval: 50
        running: false
        repeat: false
        onTriggered: {
            colorReader.path = wallpaperWindow.colorsJsonFilePath;
        }
    }

    Timer {
        id: colorWriteDelay

        interval: 50
        running: false
        repeat: false
        onTriggered: wallpaperWindow.writeColorsJson()
    }

    // ── Live wallpaper window (background layer) ──────────────────────────────
    PanelWindow {
        id: bg

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

        Image {
            id: image

            visible: !wallpaperWindow.useVideo
            source: wallpaperWindow.currentWallpaper
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
                    duration: 400
                    easing.type: Easing.OutCubic
                }

            }

        }

    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 0
        radius: 0
        color: bgPrimary

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // ── Header ────────────────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 52

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: "Wallpapers"
                        color: bgSecondary
                        font.pixelSize: 26
                        font.bold: true
                    }

                    Text {
                        text: "Auto-generated themes from the wallpaper"
                        color: bgSecondaryDark
                        font.pixelSize: 13
                    }

                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    // Video / Image toggle
                    Rectangle {
                        color: wallpaperWindow.useVideo ? bgSecondaryHover : bgSecondary
                        width: 90
                        height: 36
                        radius: 10

                        Text {
                            text: wallpaperWindow.useVideo ? "Video" : "Image"
                            anchors.centerIn: parent
                            color: bgPrimary
                            font.pixelSize: 14
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                wallpaperWindow.useVideo = !wallpaperWindow.useVideo;
                                wallpaperWindow.wallpaperDir = wallpaperWindow.useVideo ? "/home/yassine/Pictures/WallpapersVideo" : "/home/yassine/Pictures/Wallpapers";
                                wallpaperWindow.currentIndex = 0;
                                wallpaperWindow.loadWallpapers();
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }

                        }

                    }

                    // Parallax toggle
                    Rectangle {
                        color: wallpaperWindow.parallaxEnabled ? bgSecondaryHover : bgSecondary
                        width: 120
                        height: 36
                        radius: wallpaperWindow.parallaxEnabled ? 18 : 10

                        Text {
                            text: "Parallax"
                            anchors.centerIn: parent
                            color: bgPrimary
                            font.pixelSize: 14
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

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }

                        }

                        Behavior on radius {
                            NumberAnimation {
                                duration: 200
                            }

                        }

                    }

                }

            }

            // ── Wallpaper Grid ────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: bgPrimary
                radius: 16
                clip: true

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 8
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded

                    GridView {
                        id: gridView

                        cellWidth: (width - 12) / 3
                        cellHeight: cellWidth * 0.6
                        model: 0
                        clip: true

                        delegate: Item {
                            property string wallpaperPath: wallpaperWindow.wallpapers[index] || ""
                            property bool isHovered: hoverArea.containsMouse
                            property bool isCurrent: index === wallpaperWindow.currentIndex

                            width: gridView.cellWidth
                            height: gridView.cellHeight

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 5
                                radius: 12
                                color: "#2A1B42"
                                clip: true
                                // Scale animation
                                scale: isHovered ? 0.97 : (isCurrent ? 1 : 0.95)
                                // Border glow for selected
                                border.width: isCurrent ? 2 : 0
                                border.color: bgSecondary

                                Image {
                                    anchors.fill: parent
                                    source: "file://" + wallpaperPath
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: false
                                    smooth: true
                                    layer.enabled: true

                                    layer.effect: OpacityMask {

                                        maskSource: Rectangle {
                                            width: parent.width
                                            height: parent.height
                                            radius: 12
                                        }

                                    }

                                }

                                // Bottom gradient + filename
                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    height: 36
                                    color: "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: wallpaperPath.split('/').pop()
                                        color: isCurrent ? "#F0E6FF" : "#C4B3E0"
                                        font.pixelSize: 11
                                        font.bold: true
                                        elide: Text.ElideMiddle
                                        width: parent.width - 12
                                        horizontalAlignment: Text.AlignHCenter

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: 200
                                            }

                                        }

                                    }

                                    gradient: Gradient {
                                        GradientStop {
                                            position: 0
                                            color: "transparent"
                                        }

                                        GradientStop {
                                            position: 1
                                            color: "#CC000000"
                                        }

                                    }

                                }

                                // Hover highlight
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 12
                                    color: "#FFFFFF"
                                    opacity: isHovered ? 0.07 : 0

                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 130
                                        }

                                    }

                                }

                                MouseArea {
                                    id: hoverArea

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        wallpaperWindow.currentIndex = index;
                                        wallpaperWindow.setWallpaper(wallpaperPath);
                                        if (!wallpaperWindow.useVideo)
                                            wallpaperWindow.loadColors();

                                    }
                                }

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 180
                                        easing.type: Easing.OutCubic
                                    }

                                }

                                Behavior on border.width {
                                    NumberAnimation {
                                        duration: 200
                                    }

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

            // ── Color Theme Section ───────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                color: "transparent"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 6

                    // "Choose a color" label + swatches
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 4

                            Text {
                                text: "Choose a color"
                                color: secondary
                                font.pixelSize: 15
                                font.bold: true
                            }

                            Row {
                                spacing: 6

                                Repeater {
                                    model: [bgColor1, bgColor2, bgColor3, bgColor4, bgColor5, bgColor6, bgColor7]

                                    Rectangle {
                                        width: 28
                                        height: 28
                                        color: modelData
                                        radius: 6
                                        border.width: wallpaperWindow.baseColor === modelData ? 3 : 1
                                        border.color: wallpaperWindow.baseColor === modelData ? primary : Qt.rgba(1, 1, 1, 0.2)

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                wallpaperWindow.baseColor = modelData;
                                                colorWriteDelay.start();
                                            }
                                        }

                                        Behavior on border.width {
                                            NumberAnimation {
                                                duration: 150
                                            }

                                        }

                                    }

                                }

                            }

                        }

                        // Dark / Light toggle
                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 64
                            height: 30
                            radius: 50
                            color: wallpaperWindow.colorMode === 0.09 ? secondaryHover : secondary

                            Text {
                                text: wallpaperWindow.colorMode === 0.09 ? "Dark" : "Light"
                                color: primary
                                anchors.centerIn: parent
                                font.pixelSize: 11
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    wallpaperWindow.colorMode = (wallpaperWindow.colorMode === 0.8) ? 0.09 : 0.8;
                                    colorWriteDelay.start();
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }

                            }

                        }

                    }

                    // Backend selector + preview swatches
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 90

                        // Preview swatches (left)
                        Rectangle {
                            width: 170
                            height: 80
                            color: Qt.hsla(primaryDark.hslHue, Math.min(1, primaryDark.hslSaturation), 0.5, primaryDark.a)
                            radius: 10
                            anchors.bottom: parent.bottom

                            GridLayout {
                                anchors.centerIn: parent
                                columns: 5
                                rowSpacing: 5
                                columnSpacing: 5

                                Repeater {
                                    model: [derivedBg, primaryDark, primary, secondary, secondaryDark, gradient1c, gradient2c, gradient3c, secondaryHover]

                                    Rectangle {
                                        Layout.preferredWidth: 26
                                        Layout.preferredHeight: 26
                                        color: modelData
                                        radius: 5
                                    }

                                }

                            }

                        }

                        // Backend buttons (right)
                        GridLayout {
                            columns: 3
                            rowSpacing: 6
                            columnSpacing: 6
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom

                            Repeater {
                                model: wallpaperWindow.backends

                                Rectangle {
                                    Layout.preferredWidth: 100
                                    Layout.preferredHeight: 32
                                    radius: wallpaperWindow.activeBackend === modelData ? 50 : 10
                                    color: wallpaperWindow.activeBackend === modelData ? secondaryHover : secondary

                                    Text {
                                        text: modelData
                                        color: primary
                                        anchors.centerIn: parent
                                        font.pixelSize: 12
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            wallpaperWindow.activeBackend = modelData;
                                            wallpaperWindow.loadColors();
                                        }
                                    }

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                        }

                                    }

                                    Behavior on radius {
                                        NumberAnimation {
                                            duration: 200
                                        }

                                    }

                                }

                            }

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

}
