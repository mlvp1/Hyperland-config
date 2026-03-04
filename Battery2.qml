import Qt5Compat.GraphicalEffects
import QtQuick 2.15
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
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

    visible: hasBattery
    width: isCharging ? 50 : 30
    height: 30

    ColorLoader {
        id: colors
    }

    Rectangle {
        anchors.fill: parent
        color: bgPrimary
        radius: 50

        Item {
            id: batteryBody

            width: root.isCharging ? 30 : 17
            height: 16
            anchors.centerIn: parent

            Row {
                anchors.centerIn: parent
                anchors.fill: parent
                opacity: 0.9
                spacing: 1

                Text {
                    text: root.isCharging ? "" : ""
                    font.pointSize: 11
                    font.bold: true
                    color: bgSecondary
                    z: 10
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: root.battery
                    font.pointSize: 13
                    font.bold: true
                    color: bgSecondary
                    z: 10
                    anchors.verticalCenter: parent.verticalCenter
                }

            }

        }

    }

    Process {
        id: batteryCheck

        command: ["sh", "-c", "test -d /sys/class/power_supply/BAT*"]
        running: true
        onExited: function(exitCode) {
            root.hasBattery = exitCode === 0;
        }
    }

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
                // Send notification for low battery
                if (capacity <= 15 && !root.isCharging && !root.lowBatteryNotified) {
                    notificationProc.running = true;
                    root.lowBatteryNotified = true;
                } else if (capacity > 15 || root.isCharging) {
                    root.lowBatteryNotified = false;
                }
            }
        }

    }

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

    Process {
        id: notificationProc

        command: ["notify-send", "-u", "critical", "-i", "battery-caution", "Low Battery", `Battery level is at ${root.batteryLevel}%. Please plug in your charger.`]
        running: false
    }

    Timer {
        interval: 5000
        running: root.hasBattery
        repeat: true
        onTriggered: {
            batteryProc.running = true;
            chargingProc.running = true;
        }
    }

    PopupWindow {
        width: 200
        height: 200
        color: "transparent"
        visible: false

        anchor {
            item: topBar
            edges: Edges.Bottom
            rect.y: root.y + root.height + 8
        }

        Rectangle {
            width: parent.width
            height: parent.height
            color: "white"
        }

    }

    Behavior on width {
        NumberAnimation {
            duration: 300
        }

    }

}
