import Qt5Compat.GraphicalEffects
import QtQuick 2.15
import QtQuick.Controls 2.15
import Quickshell.Io
import "../services"

Item {
    id: root

    property real volume: 0.5
    property bool isMuted: false
    property real lastVolume: volume
    property string iconName: "volume_up"
    property real o: 1
    property real o1: 1
    property bool ok: true
    property string iconSource: "../icons/sound/volume-off.png"

    ColorLoader {
        id: colors
    }
    
    property string bgColor: colors.bgColor
    property string bgPrimary: colors.bgPrimary
    property string bgSecondary: colors.bgSecondary
    property string bgSecondaryHover: colors.bgSecondaryHover
    property string bgPrimaryDark: colors.bgPrimaryDark
    property string bgSecondaryDark: colors.bgSecondaryDark
    property string bgGradient1: colors.bgGradient1
    property string bgGradient2: colors.bgGradient2
    property string bgGradient3: colors.bgGradient3

    function updateIcon() {
        if (isMuted || volume === 0) {
            iconSource = "../icons/sound/volume-mute.png";
            o = 0;
            o1 = 0;
        } else if (volume < 0.33) {
            iconSource = "../icons/sound/volume-off.png";
            o = 0;
            o1 = ok ? 1 : 0;
        } else if (volume < 0.66) {
            iconSource = "../icons/sound/volume-off.png";
            o = ok ? 1 : 0;
            o1 = 1;
        } else {
            iconSource = "../icons/sound/volume-off.png";
            o = 1;
            o1 = 1;
        }
    }

    function playSourceAnimation() {
        if (volume > lastVolume)
            ok = true;
        else if (volume < lastVolume)
            ok = false;
        lastVolume = volume;
    }

    width: 385
    height: 60

    // Monitor volume changes from system
    Process {
        id: volumeMonitor
        command: ["pactl", "subscribe"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                if (data.includes("Event 'change' on sink")) {
                    volumeCheckTimer.restart();
                }
            }
        }
    }

    Timer {
        id: volumeCheckTimer
        interval: 50
        repeat: false
        onTriggered: {
            volumeGetter.running = false;
            volumeGetter.running = true;
            muteGetter.running = false;
            muteGetter.running = true;
        }
    }

    // Get current volume level
    Process {
        id: volumeGetter
        command: ["pactl", "get-sink-volume", "@DEFAULT_SINK@"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                const match = data.match(/(\d+)%/);
                if (match && match[1]) {
                    const newVolume = parseInt(match[1]) / 100.0;
                    if (Math.abs(newVolume - root.volume) > 0.01) {
                        root.volume = newVolume;
                        playSourceAnimation();
                        updateIcon();
                    }
                }
            }
        }
    }

    // Get current mute state
    Process {
        id: muteGetter
        command: ["pactl", "get-sink-mute", "@DEFAULT_SINK@"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                const newMuted = data.trim().toLowerCase().includes("yes");
                if (newMuted !== root.isMuted) {
                    root.isMuted = newMuted;
                    updateIcon();
                }
            }
        }
    }

    // Initial volume and mute check on startup
    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: {
            volumeGetter.running = true;
            muteGetter.running = true;
        }
    }

    // Periodic refresh (backup in case events are missed)
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            volumeGetter.running = false;
            volumeGetter.running = true;
            muteGetter.running = false;
            muteGetter.running = true;
        }
    }

    Process {
        id: muteToggle
        command: ["pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle"]
        onExited: {
            volumeCheckTimer.restart();
        }
    }

    Process {
        id: volSet
        command: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", "50%"]
        onExited: {
            volumeCheckTimer.restart();
        }
    }

    Timer {
        id: updateTimer
        interval: 100
        repeat: false
        onTriggered: {
            const newVol = Math.round(root.volume * 100);
            volSet.command = ["pactl", "set-sink-volume", "@DEFAULT_SINK@", newVol + "%"];
            volSet.running = true;
        }
    }

    // Background container with rounded corners
    Rectangle {
        id: container
        width: 385
        height: 60
        radius: height / 2
        color: bgPrimaryDark
        layer.enabled: true
        anchors.centerIn: parent

        layer.effect: InnerShadow {
            horizontalOffset: 0
            verticalOffset: 2
            radius: 8
            samples: 16
            color: "#80000000"
            spread: 0.2
        }
    }

    Rectangle {
        width: 385
        height: 60
        radius: height / 2
        color: "transparent"
        layer.enabled: true
        anchors.centerIn: parent
        
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 4
            radius: 24
            samples: 32
            color: "red"
            transparentBorder: true
        }
    }

    Rectangle {
        id: progressFill
        x: (parent.width - 385) / 2
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: isMuted ? 60 : Math.max(60, 385 * root.volume)
        radius: 30
        color: bgPrimary

        Behavior on width {
            enabled: !sliderArea.pressed
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }

    Rectangle {
        id: iconCircle
        width: 48
        height: 48
        radius: 24
        x: (parent.width - 385) / 2 + 6
        anchors.verticalCenter: parent.verticalCenter
        color: bgSecondary

        // Volume icon (high)
        Image {
            id: volumeIcon
            source: "../icons/sound/volume.png"
            width: 24
            height: 24
            smooth: true
            fillMode: Image.PreserveAspectFit
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            opacity: o

            ColorOverlay {
                anchors.fill: volumeIcon
                source: volumeIcon
                color: bgPrimary
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

        // Volume icon (medium)
        Image {
            id: image1
            source: "../icons/sound/volume-down.png"
            width: 24
            height: 24
            smooth: true
            fillMode: Image.PreserveAspectFit
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            opacity: o1

            ColorOverlay {
                anchors.fill: image1
                source: image1
                color: bgPrimary
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

        // Volume icon (low/mute)
        Image {
            id: image2
            source: iconSource
            width: 24
            height: 24
            smooth: true
            fillMode: Image.PreserveAspectFit
            x: 12
            anchors.verticalCenter: parent.verticalCenter

            ColorOverlay {
                anchors.fill: image2
                source: image2
                color: bgPrimary
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                muteToggle.running = true;
            }
        }
    }

    // Slider interaction area
    MouseArea {
        id: sliderArea

        function updateVolume(x) {
            var effectiveWidth = container.width;
            var newVolume = Math.max(0, Math.min(1, x / effectiveWidth));
            root.volume = newVolume;
            root.isMuted = false;
            
            // Unmute if muted
   
        
            
            updateIcon();
            updateTimer.restart();
            playSourceAnimation();
        }

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: function(mouse) {
            updateVolume(mouse.x);
        }
        onPositionChanged: function(mouse) {
            if (pressed)
                updateVolume(mouse.x);
        }
    }
}