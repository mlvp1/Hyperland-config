import QtMultimedia
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "Widgets"
import "services"

PanelWindow {
    property string videoSource: "file:///home/yassine/.config/quickshell/gg.mp4"
    property real shift: 0
    property int currentWorkspace: 1
    property real shiftAmount: 10
    property string bgColor: colors.bgColor
    property string bgPrimary: colors.bgPrimary
    property string bgSecondary: colors.bgSecondary
    property string bgSecondaryHover: colors.bgSecondaryHover
    property string bgPrimaryDark: colors.bgPrimaryDark
    property string bgSecondaryDark: colors.bgSecondaryDark
    property string bgGradient1: colors.bgGradient1
    property string bgGradient2: colors.bgGradient2
    property string bgGradient3: colors.bgGradient3
    property bool isopen: false

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "depth-wallpaper-below"

    Component.onCompleted: {
        if (Hyprland.focusedMonitor && Hyprland.focusedMonitor.activeWorkspace) {
            currentWorkspace = Hyprland.focusedMonitor.activeWorkspace.id;
            shift = (currentWorkspace - 1) * shiftAmount;
        }
    }

    ColorLoader {
        id: colors
    }

    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    Connections {
        target: Hyprland.focusedMonitor
        function onActiveWorkspaceChanged() {
            if (Hyprland.focusedMonitor.activeWorkspace) {
                currentWorkspace = Hyprland.focusedMonitor.activeWorkspace.id;
                shift = (currentWorkspace - 1) * shiftAmount;
            }
        }
    }

    MediaPlayer {
        id: player
        source: videoSource
        videoOutput: videoOut
        audioOutput: AudioOutput { muted: true }
        Component.onCompleted: player.play()
    }

    VideoOutput {
        id: videoOut
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
        x: isopen ? 10 : 0

        Behavior on x {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Item {
        x: shift + 150
        y: 200

        Text {
            text: Qt.formatDateTime(clock.date, "hh:mm AP")
            font.pixelSize: 100
            font.bold: true
            color: bgSecondary
        }

        Behavior on x {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }
    }
}