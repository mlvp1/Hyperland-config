// ButtonPanelPopup.qml
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

PopupWindow {
    id: buttonPanelPopup

    property bool opened: false
    property int expandedWidth: 560
    property int expandedHeight: 150
    property Item notchItem
    property bool contentVisible: false

    width: expandedWidth
    height: expandedHeight + (notchItem ? notchItem.height : 40)
    visible: contentVisible
    color: "transparent"

    anchor {
        item: notchItem
        rect.x: (notchItem.width / 2 - width / 2) + 1
        rect.y: notchItem.height
    }

    // Shutdown process
    Process {
        id: shutdownProc
        running: false
        command: ["systemctl", "poweroff"]
    }

    // Lock process
    Process {
        id: lockProc
        running: false
        command: ["hyprlock"]
    }

    // Restart process
    Process {
        id: restartProc
        running: false
        command: ["systemctl", "reboot"]
    }

    Timer {
        id: closeDelayTimer
        interval: 400
        repeat: false
        onTriggered: {
            if (!buttonPopupMouseArea.containsMouse) {
                opened = false
            }
        }
    }

    Timer {
        id: contentCloseTimer
        interval: 800
        repeat: false
        onTriggered: {
            if (!buttonPopupMouseArea.containsMouse) {
                contentVisible = false
            }
        }
    }

    function startCloseTimer() {
        closeDelayTimer.start()
        contentCloseTimer.start()
    }

    function stopCloseTimer() {
        closeDelayTimer.stop()
        contentCloseTimer.stop()
    }

    onOpenedChanged: {
        if (opened) {
            contentVisible = true
            stopCloseTimer()
        } else {
            startCloseTimer()
        }
    }

    MouseArea {
        id: buttonPopupMouseArea
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            stopCloseTimer()
        }

        onExited: {
            startCloseTimer()
        }
    }

    Canvas {
        id: buttonPopupContent
        x: (parent.width - width) / 2
        y: 0

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            var bottomRadius = 30;
            var gradient = ctx.createLinearGradient(0, 0, 0, height);
            gradient.addColorStop(0, "#02020D");
            gradient.addColorStop(1, "#02020D");
            ctx.fillStyle = gradient;

            ctx.beginPath();
            ctx.moveTo(0, 0);
            ctx.lineTo(width, 0);
            ctx.lineTo(width, height - bottomRadius);
            ctx.arcTo(width, height, width - bottomRadius, height, bottomRadius);
            ctx.lineTo(bottomRadius, height);
            ctx.arcTo(0, height, 0, height - bottomRadius, bottomRadius);
            ctx.lineTo(0, 0);
            ctx.closePath();
            ctx.fill();
        }

        opacity: 1
        width: opened ? expandedWidth : (notchItem ? notchItem.width : 0)
        height: opened ? expandedHeight : 0

        Behavior on width {
            NumberAnimation {
                duration: notchItem ? notchItem.animationDuration : 450
                easing.type: Easing.InOutCubic
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: 400
                easing.type: Easing.InOutCubic
            }
        }

        Item {
            anchors.fill: parent
            opacity: opened ? 1 : 0
            scale: opened ? 1 : 0.8

            layer.enabled: true
            layer.effect: FastBlur {
                radius: opened ? 0 : 50
                Behavior on radius {
                    NumberAnimation { duration: 400; easing.type: Easing.InOutQuad }
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: opened ? 150 : 500
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: opened ? 150 : 200
                    easing.type: Easing.InOutQuad
                }
            }

            Row {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20

                // Restart Button
                Rectangle {
                    width: 100
                    height: 100
                    radius: 15
                    color: "#1a1a1a"

                    Behavior on color {
                        ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: "white"
                        font.pixelSize: 50
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            restartProc.running = true;
                        }
                    }
                }

                // Shutdown Button
                Rectangle {
                    width: 100
                    height: 100
                    radius: 15
                    color: "#1a1a1a"

                    Behavior on color {
                        ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: "white"
                        font.pixelSize: 50
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            shutdownProc.running = true;
                        }
                    }
                }

                // Lock Button
                Rectangle {
                    width: 100
                    height: 100
                    radius: 15
                    color: "#1a1a1a"

                    Behavior on color {
                        ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: "white"
                        font.pixelSize: 50
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            lockProc.running = true;
                        }
                    }
                }

                // Custom Button 4
                Rectangle {
                    width: 100
                    height: 100
                    radius: 15
                    color: "#1a1a1a"

                    Behavior on color {
                        ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "?"
                        color: "white"
                        font.pixelSize: 50
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            // Add your custom action here
                            console.log("Custom button 4 clicked")
                        }
                    }
                }
            }
        }
    }
}