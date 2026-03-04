// VolumeModule.qml
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import Quickshell.Io

Item {
    id: volumeModule

    // property bool visible: false
    property real volumeLevel: 1
    property real lastVolume: volumeLevel
    property bool ok: true
    property real o: 1
    property real o1: 1
    property string iconSource: "../icons/sound/volume.png"

    Timer {
        id: volumeHideTimer
        interval: 2000
        repeat: false
        onTriggered: {
            volumeModule.visible = false
        }
    }

    // Volume monitoring process
    Process {
        id: volumeMonitor
        command: ["pactl", "subscribe"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                if (data.includes("Event 'change' on sink")) {
                    volumeCheckTimer.restart()
                }
            }
        }
    }

    // Get current volume level
    Process {
        id: volumeGetter
        command: ["pactl", "get-sink-volume", "@DEFAULT_SINK@"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                const match = data.match(/(\d+)%/)
                if (match && match[1]) {
                    const newVolume = parseInt(match[1]) / 100.0
                    if (Math.abs(newVolume - volumeLevel) > 0.01) {
                        volumeLevel = newVolume
                        playVolumeAnimation()
                        volumeModule.visible = true
                        volumeHideTimer.restart()
                    }
                }
            }
        }
    }

    Timer {
        id: volumeCheckTimer
        interval: 50
        repeat: false
        onTriggered: {
            volumeGetter.running = true
        }
    }

    Process {
        id: volSet
        command: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", "50%"]
    }

    Timer {
        id: updateTimer
        interval: 100
        repeat: false
        onTriggered: {
            volSet.command = ["pactl", "set-sink-volume", "@DEFAULT_SINK@", Math.round(volumeLevel * 100) + "%"];
            volSet.running = true;
        }
    }

    Component.onCompleted: {
        volumeGetter.running = true
    }

    function updateVolumeIcon() {
        if (volumeLevel === 0) {
            iconSource = "../icons/sound/volume-mute.png";
        } else if (volumeLevel < 0.5) {
            iconSource = "../icons/sound/volume-off.png";
            if (ok) o1 = 1;
            else o1 = 0;
        } else if (volumeLevel < 0.7) {
            if (ok) o = 1;
            else o = 0;
        } else if (volumeLevel > 0.1) {
            iconSource = "../icons/sound/volume-off.png";
        }
    }

    function playVolumeAnimation() {
        if (volumeLevel > lastVolume) ok = true;
        else if (volumeLevel < lastVolume) ok = false;
        lastVolume = volumeLevel;
        updateVolumeIcon();
    }

    function handleWheel(wheel) {
        if (wheel.angleDelta.y > 0) {
            volumeLevel = Math.min(1.0, volumeLevel + 0.05)
        } else if (wheel.angleDelta.y < 0) {
            volumeLevel = Math.max(0.0, volumeLevel - 0.05)
        }
        volumeModule.visible = true
        volumeHideTimer.restart()
        playVolumeAnimation()
        updateTimer.restart()
    }

    // Volume icon on the left
    Item {
        id: volumeIconContainer
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 20
        width: 100
        height: 24
        opacity: volumeModule.visible ? 1 : 0
        scale: volumeModule.visible ? 1 : 0.8
        z: 6

        layer.enabled: true
        layer.effect: FastBlur {
            radius: volumeModule.visible ? 0 : 32
            Behavior on radius {
                NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
        Behavior on scale {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        Item {
            width: 20
            height: 20
            anchors.verticalCenter: parent.verticalCenter

            // High volume icon
            Image {
                id: volumeIcon
                source: "../icons/sound/volume.png"
                width: 20
                height: 20
                smooth: true
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent
                opacity: o

                ColorOverlay {
                    anchors.fill: volumeIcon
                    source: volumeIcon
                    color: "white"
                }

                Behavior on opacity {
                    NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
                }
            }

            // Medium volume icon
            Image {
                id: volumeDownIcon
                source: "../icons/sound/volume-down.png"
                width: 20
                height: 20
                smooth: true
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent
                opacity: o1

                ColorOverlay {
                    anchors.fill: volumeDownIcon
                    source: volumeDownIcon
                    color: "white"
                }

                Behavior on opacity {
                    NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
                }
            }

            // Base icon
            Image {
                id: baseVolumeIcon
                source: iconSource
                width: 20
                height: 20
                smooth: true
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent

                ColorOverlay {
                    anchors.fill: baseVolumeIcon
                    source: baseVolumeIcon
                    color: "white"
                }
            }
        }

        Text {
            text: "Volume"
            color: "white"
            font.pixelSize: 12
            font.bold: true
            anchors.left: parent.left
            anchors.leftMargin: 30
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Volume slider on the right
    Item {
        id: volumeContainer
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 20
        width: 70
        height: 30
        opacity: volumeModule.visible ? 1 : 0
        scale: volumeModule.visible ? 1 : 0.8
        z: 6

        layer.enabled: true
        layer.effect: FastBlur {
            radius: volumeModule.visible ? 0 : 32
            Behavior on radius {
                NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
        Behavior on scale {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        Rectangle {
            id: volumeSliderBg
            width: 70
            height: 6
            radius: 3
            color: "#333333"
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                width: parent.width * volumeLevel
                height: parent.height
                radius: parent.radius
                color: "#ffffff"

                Behavior on width {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }
            }

            MouseArea {
                id: volumeSliderArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                visible: false

                function updateVolume(x) {
                    var newVolume = Math.max(0, Math.min(1, x / volumeSliderBg.width));
                    volumeLevel = newVolume;
                    playVolumeAnimation();
                    updateTimer.restart();
                    volumeHideTimer.restart();
                }

                onPressed: function(mouse) {
                    updateVolume(mouse.x);
                }

                onPositionChanged: function(mouse) {
                    if (pressed) updateVolume(mouse.x);
                }
            }
        }
    }
}