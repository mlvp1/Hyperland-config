import Qt5Compat.GraphicalEffects
import QtQuick 2.15
import QtQuick.Controls 2.15
import Quickshell.Io
import "../services"

Item {
    id: root

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

    property int maxBrightness: 800
    property int brightness: 800
    property real normalizedBrightness: brightness / maxBrightness
    property string iconSource: "../icons/brightness/brightness.png"
    property string cl: bgPrimary
    property real o: 1
    property real o1: 1
    property bool ok: true
    property int lastBrightness: brightness

    function updateIcon() {
        if (brightness < 300) {
            iconSource = "../icons/brightness/brightness-low.png";
            cl = bgPrimary;
        } else if (brightness < 500) {
            iconSource = "../icons/brightness/brightness.png";
            cl = bgPrimary;
        } else if (brightness > 500) {
            iconSource = "../icons/brightness/brightness.png";
            cl = bgPrimary;
        }
    }

    function playSourceAnimation() {
        if (brightness > lastBrightness)
            ok = true;
        else if (brightness < lastBrightness)
            ok = false;
        lastBrightness = brightness;
    }

    width: 385
    height: 60
    
    Component.onCompleted: {
        updateIcon();
    }

    Process {
        id: setBrightness

        command: ["sh", "-c", "echo " + brightness + " | sudo tee /sys/class/backlight/nvidia_wmi_ec_backlight/brightness"]
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

    // Active progress fill
    Rectangle {
        id: progressFill

        x: (parent.width - 385) / 2
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: Math.max(60, 385 * root.normalizedBrightness)
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

    // Icon circle on the left
    Rectangle {
        id: iconCircle

        width: 48
        height: 48
        radius: 24
        x: (parent.width - 385) / 2 + 6
        anchors.verticalCenter: parent.verticalCenter
        color: bgSecondary

        // Brightness icon with rotation and scale
        Image {
            id: brightnessIcon

            source: iconSource
            width: 24
            height: 24
            smooth: true
            fillMode: Image.PreserveAspectFit
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            rotation: root.normalizedBrightness * 360
            scale: 0.8 + (root.normalizedBrightness * 0.3)

            ColorOverlay {
                anchors.fill: brightnessIcon
                source: brightnessIcon
                color: bgPrimary

                Behavior on color {
                    ColorAnimation {
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Behavior on rotation {
                NumberAnimation {
                    duration: 50
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutBack
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                // Toggle between low and max brightness
                if (brightness > maxBrightness / 2)
                    brightness = 100;
                else
                    brightness = maxBrightness;
                setBrightness.command = ["sh", "-c", "echo " + brightness + " | sudo tee /sys/class/backlight/nvidia_wmi_ec_backlight/brightness"];
                setBrightness.running = true;
                updateIcon();
                playSourceAnimation();
            }
        }
    }

    // Slider interaction area
    MouseArea {
        id: sliderArea

        function updateBrightness(x) {
            var effectiveWidth = container.width;
            var newBrightness = Math.max(10, Math.min(maxBrightness, (x / effectiveWidth) * maxBrightness));
            root.brightness = Math.round(newBrightness);
            setBrightness.command = ["sh", "-c", "echo " + root.brightness + " | sudo tee /sys/class/backlight/nvidia_wmi_ec_backlight/brightness"];
            setBrightness.running = true;
            updateIcon();
            playSourceAnimation();
        }

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: function(mouse) {
            updateBrightness(mouse.x);
        }
        onPositionChanged: function(mouse) {
            if (pressed)
                updateBrightness(mouse.x);
        }
    }
}