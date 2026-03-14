import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "Widgets"
import "services"

Item {
    id: root

    property string bgColor: colors.bgColor
    property string bgPrimary: colors.bgPrimary
    property string bgSecondary: colors.bgSecondary
    property string bgSecondaryHover: colors.bgSecondaryHover
    property string bgPrimaryDark: colors.bgPrimaryDark
    property string bgSecondaryDark: colors.bgSecondaryDark
    property string battery: ""
    property string c: bgSecondary
    property bool hasBattery: false
    property bool isCharging: false
    property bool lowBatteryNotified: false
    property int batteryLevel: 100
    // GPU mode properties
    property string currentGpuMode: "Unknown"
    property bool hasGpu: false
    // Refresh rate properties
    property int currentRefreshRate: 144
    property string monitorName: "eDP-1" // Default monitor name, adjust as needed
    property string monitorResolution: "1920x1080" // Default resolution, will be auto-detected

    // Function to update battery color based on charging status and level
    function updateBatteryColor() {
        if (isCharging)
            c = "#009E60";
        else if (batteryLevel < 20)
            c = "#ff5555";
        else if (batteryLevel < 50)
            c = "#f1fa8c";
        else
            c = bgSecondary;
    }

    visible: hasBattery
    width: 50
    height: 31

    ColorLoader {
        id: colors
    }

    Rectangle {
        id: topBar

        anchors.fill: parent
        color: bgPrimary
        radius: 14

        MouseArea {
            anchors.fill: parent
            onClicked: {
                popup.opened = !popup.opened;
                
            }
        }

        Item {
            width: 45
            height: 25
            anchors.centerIn: parent

            Rectangle {
                width: 30
                height: 16
                radius: 5
                color: bgPrimaryDark
                anchors.centerIn: parent
            }

            Rectangle {
                id: batteryBody

                width: 30
                height: 16
                radius: 5
                color: "transparent"
                border.color: c
                border.width: 1.5
                anchors.centerIn: parent

                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.max(0, (batteryBody.width - 6) * (root.batteryLevel / 100))
                    height: batteryBody.height - 4
                    radius: 2
                    color: c
                    opacity: 0.9

                    Behavior on width {
                        NumberAnimation {
                            duration: 300
                        }

                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 300
                        }

                    }

                }

                Text {
                    text: root.isCharging ? "" : root.battery
                    font.pointSize: 10
                    font.bold: true
                    color: root.isCharging ? "white" : "white"
                    anchors.centerIn: parent
                    z: 10
                }

            }

            Rectangle {
                width: 2
                height: 8
                radius: 1
                color: c
                anchors.left: batteryBody.right
                anchors.leftMargin: 1
                anchors.verticalCenter: batteryBody.verticalCenter

                Behavior on color {
                    ColorAnimation {
                        duration: 300
                    }

                }

            }

        }

    }

    PopupWindow {
        id: popup

        property bool opened: false

        width: 200
        height: hasGpu ? 125 : 70
        visible: false
        color: "transparent"

        anchor {
            item: root
            edges: Edges.Bottom
            rect.y: root.height + 15
        }

        Rectangle {
            id: popupContent

            anchors.fill: parent
            color: bgColor
            radius: 20
            transformOrigin: Item.Top
            opacity: popup.opened ? 1 : 0
            scale: popup.opened ? 1 : 0.92

            Row {
                // GPU Mode Buttons (only visible if GPU is available)

                anchors.fill: parent
                anchors.margins: 15
                spacing: 12

                Rectangle {
                    width: 50
                    height: 50
                    color: bgPrimary
                    radius: 10
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    id: toggleTrack1

                    property bool isOn: false

                    anchors.right: parent.right
                    implicitWidth: 100
                    implicitHeight: 40
                    color: bgPrimary
                    radius: 50
                    border.color: bgSecondary
                    border.width: 0

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            toggleTrack1.isOn = !toggleTrack1.isOn;
                            if (toggleTrack1.isOn || root.currentRefreshRate === "60")
                                var rate = ref.text;

                            setRefreshRate.command = ["hyprctl", "keyword", "monitor", root.monitorName + "," + root.monitorResolution + "@" + rate];
                            setRefreshRate.running = true;
                            console.log("Setting refresh rate to: " + rate + "Hz");
                        }
                    }

                    Rectangle {
                        id: toggleThumb1

                        anchors.fill: parent
                        anchors.margins: 5
                        anchors.leftMargin: toggleTrack1.isOn ? 5 : 40
                        anchors.rightMargin: toggleTrack1.isOn ? 40 : 5
                        color: bgSecondary
                        radius: 50

                        Text {
                            id: ref

                            text: toggleTrack1.isOn ? "60" : "144"
                            anchors.centerIn: parent
                            font.pixelSize: 18
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

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutBack
                    easing.overshoot: 0.5
                }

            }

            transform: Translate {
                id: slideTransform

                y: popup.opened ? 0 : -popupContent.height * 0.3

                Behavior on y {
                    NumberAnimation {
                        duration: 550
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.6
                    }

                }

            }

        }

        Timer {
            id: hideTimer

            interval: 350
            repeat: false
            onTriggered: {
                if (!popup.opened)
                    popup.visible = false;

            }
        }

        Connections {
            function onOpenedChanged() {
                if (popup.opened) {
                    popup.visible = true;
                    hideTimer.stop();
                } else {
                    hideTimer.start();
                }
            }

            target: popup
        }

    }

    PanelWindow {
        id: warrning

        visible: false
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "bg-panel"
        WlrLayershell.exclusiveZone: -1
        onVisibleChanged: {
            if (visible) {
                // Show the warning panel with background
                warrning.color = "#66000000";
                popupWarning.opacity = 1;
            }
        }

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        // Timer to hide everything after close button is clicked
        Timer {
            id: hideWarningTimer

            interval: 1000
            repeat: false
            onTriggered: {
                warrning.visible = false;
            }
        }

        Rectangle {
            id: popupWarning

            width: 400
            height: 100
            anchors.centerIn: parent
            color: "red"
            opacity: 0
            radius: 10

            Text {
                anchors.centerIn: parent
                text: "Battery Critical: " + root.batteryLevel + "%"
                color: "white"
                font.pointSize: 16
                font.bold: true
            }

            Rectangle {
                width: 20
                height: 20
                radius: 20
                color: "black"
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.top: parent.top
                anchors.topMargin: 10

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // Start fade out animations
                        popupWarning.opacity = 0;
                        warrning.color = "transparent";
                        // After animations complete, hide the panel window
                        hideWarningTimer.start();
                    }
                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }

            }

        }

        Behavior on color {
            ColorAnimation {
                duration: 300
            }

        }

    }

    // Check if battery exists
    Process {
        id: batteryCheck

        command: ["sh", "-c", "test -d /sys/class/power_supply/BAT*"]
        running: true
        onExited: function(exitCode) {
            root.hasBattery = exitCode === 0;
        }
    }

    // Check if supergfxctl is available
    Process {
        id: gpuCheck

        command: ["sh", "-c", "command -v supergfxctl"]
        running: true
        onExited: function(exitCode) {
            root.hasGpu = exitCode === 0;
            if (root.hasGpu)
                getGpuMode.running = true;

        }
    }

    // Get current GPU mode
    Process {
        id: getGpuMode

        command: ["supergfxctl", "-g"]
        running: false

        stdout: SplitParser {
            onRead: function(data) {
                const mode = data.trim();
                // Capitalize first letter
                root.currentGpuMode = mode.charAt(0).toUpperCase() + mode.slice(1);
            }
        }

    }

    // Set GPU mode
    Process {
        id: setGpuMode

        command: []
        running: false
        onExited: function(exitCode) {
            if (exitCode === 0)
                getGpuMode.running = true;

        }
    }

    // Get current refresh rate
    Process {
        id: getRefreshRate

        command: ["sh", "-c", "hyprctl monitors -j | jq -r '.[0].refreshRate' | cut -d. -f1"]
        running: true

        stdout: SplitParser {
            onRead: function(data) {
                const rate = parseInt(data.trim());
                if (!isNaN(rate))
                    root.currentRefreshRate = rate;

            }
        }

    }

    // Get monitor resolution
    Process {
        id: getMonitorResolution

        command: ["sh", "-c", "hyprctl monitors -j | jq -r '.[0] | \"\\(.width)x\\(.height)\"'"]
        running: true

        stdout: SplitParser {
            onRead: function(data) {
                const resolution = data.trim();
                if (resolution && resolution.includes("x")) {
                    root.monitorResolution = resolution;
                    console.log("Detected monitor resolution: " + resolution);
                }
            }
        }

    }

    // Set refresh rate
    Process {
        // Wait a bit for Hyprland to apply the change, then check

        id: setRefreshRate

        command: []
        running: false
        onExited: function(exitCode) {
            if (exitCode === 0)
                refreshRateUpdateTimer.start();

        }
    }

    // Timer to update refresh rate after change
    Timer {
        id: refreshRateUpdateTimer

        interval: 500
        repeat: false
        onTriggered: {
            getRefreshRate.running = true;
        }
    }

    // Battery capacity monitoring
    Process {
        id: batteryProc

        command: ["sh", "-c", "cat /sys/class/power_supply/BAT*/capacity"]
        running: root.hasBattery

        stdout: SplitParser {
            onRead: function(data) {
                const capacity = parseInt(data.trim());
                root.batteryLevel = capacity;
                root.battery = `${capacity}`;
                updateBatteryColor();
                if (capacity <= 15 && !root.isCharging && !root.lowBatteryNotified) {
                    notificationProc.running = true;
                    root.lowBatteryNotified = true;
                } else if (capacity > 15 || root.isCharging) {
                    root.lowBatteryNotified = false;
                }
                // Show critical battery warning at 5%
                if (capacity === 5)
                    warrning.visible = true;

            }
        }

    }

    // Charging status monitoring
    Process {
        id: chargingProc

        command: ["sh", "-c", "cat /sys/class/power_supply/BAT*/status"]
        running: root.hasBattery

        stdout: SplitParser {
            onRead: function(data) {
                const status = data.trim();
                root.isCharging = (status === "Charging" || status === "Full");
                updateBatteryColor();
            }
        }

    }

    // Low battery notification
    Process {
        id: notificationProc

        command: ["notify-send", "-u", "critical", "-i", "battery-caution", "Low Battery", `Battery level is at ${root.batteryLevel}%. Please plug in your charger.`]
        running: false
    }

    // Update battery status every 5 seconds
    Timer {
        interval: 5000
        running: root.hasBattery
        repeat: true
        onTriggered: {
            batteryProc.running = true;
            chargingProc.running = true;
        }
    }

    // Update GPU mode every 10 seconds
    Timer {
        interval: 10000
        running: root.hasGpu
        repeat: true
        onTriggered: {
            getGpuMode.running = true;
        }
    }

    // Update refresh rate every 10 seconds
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            getRefreshRate.running = true;
        }
    }

}
