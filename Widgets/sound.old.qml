import Qt5Compat.GraphicalEffects
import QtQuick 2.15
import QtQuick.Controls 2.15
import Quickshell.Io

Item {
    // ================= ICON LOGIC =================
    // ================= DIRECTION CHECK =================
    // ================= PACTL =================
    // ================= SLIDER =================
    // ================= MUTE BUTTON =================
    // ================= ICON =================
    // ================= ANIMATIONS =================

    id: root

    property real volume: 1
    property real o: 1
    property real o1: 1
    property bool ok: true
    property real lastVolume: volume
    property string iconSource: "../icons/sound/volume-off.png"

    function updateIcon() {
        if (volume === 0) {
            iconSource = "../icons/sound/volume-mute.png";
        } else if (volume < 0.5) {
            iconSource = "../icons/sound/volume-off.png";
            if (ok)
                o1 = 1;
            else
                o1 = 0;
        } else if (volume < 0.7) {
            if (ok)
                o = 1;
            else
                o = 0;
        } else if (volume > 0.1) {
            console.log("hi");
            iconSource = "../icons/sound/volume-off.png";
        }
    }

    function playSourceAnimation() {
        if (volume > lastVolume)
            ok = true;
        else if (volume < lastVolume)
            ok = false;
        lastVolume = volume;
    }

    width: 300
    height: 50

    Process {
        id: muteToggle

        command: ["pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle"]
    }

    Process {
        id: volSet

        command: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", "50%"]
    }

    Timer {
        id: updateTimer

        interval: 200
        repeat: false
        onTriggered: {
            volSet.command = ["pactl", "set-sink-volume", "@DEFAULT_SINK@", Math.round(root.volume * 100) + "%"];
            volSet.running = true;
        }
    }

    Slider {
        id: volumeSlider

        anchors.fill: parent
        anchors.margins: 10
        from: 0
        to: 1
        value: root.volume
        onMoved: {
            root.volume = value;
            updateIcon(); // source may change here
            updateTimer.restart();
            playSourceAnimation();
        }

        background: Rectangle {
            x: volumeSlider.leftPadding
            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2 
            width: volumeSlider.availableWidth
            height: 50
            radius: 25
            color: "#3b4252"

            Rectangle {
                width: volumeSlider.visualPosition * parent.width 
                height: parent.height
                radius: 25
                color: "#bd93f9"
     

            }


        }

        handle: Item {
        }

    }

    Rectangle {
        width: 50
        height: 50
        radius: 10
        color: "#bd93f9"
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: -60

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                muteToggle.running = true;
                root.volume = 0;
                updateIcon();
                fadeOut.restart();
            }
        }

    }

    Image {
        id: volumeIcon

        source: "../icons/sound/volume.png"
        width: 20
        height: 20
        smooth: true
        fillMode: Image.PreserveAspectFit
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        opacity: o

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }

        }

    }

    Image {
        source: "../icons/sound/volume-down.png"
        width: 20
        height: 20
        smooth: true
        fillMode: Image.PreserveAspectFit
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        opacity: o1

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }

        }

    }

    Image {
        source: iconSource
        width: 20
        height: 20
        smooth: true
        fillMode: Image.PreserveAspectFit
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
    }

}
