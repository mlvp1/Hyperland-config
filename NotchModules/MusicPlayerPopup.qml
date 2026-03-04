// MusicPlayerPopup.qml
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris
import "../services"

PopupWindow {
    id: musicPlayerPopup
    property string bgColor: colors.bgColor
    property string bgPrimary: colors.bgPrimary
    property string bgSecondary: colors.bgSecondary
    property string bgSecondaryHover: colors.bgSecondaryHover
    property string bgPrimaryDark: colors.bgPrimaryDark
    property string bgSecondaryDark: colors.bgSecondaryDark
    property bool opened: false
    property int expandedWidth: 640
    property int expandedHeight: 200
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
      ColorLoader {
        id: colors
    }

    Timer {
        id: closeDelayTimer
        interval: 400
        repeat: false
        onTriggered: {
            if (!popupMouseArea.containsMouse) {
                opened = false
            }
        }
    }

    Timer {
        id: contentCloseTimer
        interval: 800
        repeat: false
        onTriggered: {
            if (!popupMouseArea.containsMouse) {
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

    function formatTime(seconds) {
        const s = Math.floor(seconds)
        const m = Math.floor(s / 60)
        const sec = s % 60
        return `${m}:${sec.toString().padStart(2, '0')}`
    }

    MouseArea {
        id: popupMouseArea
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
        id: popupContent
        x: (parent.width - width) / 2
        y: 0

        property real position: activePlayer?.position ?? 0
        property real length: activePlayer?.length ?? 0
        property real progress: length > 0 ? position / length : 0
        property var activePlayer: MprisService.activePlayer

        Timer {
            interval: 500
            repeat: true
            running: MprisService.isPlaying && popupContent.activePlayer
            onTriggered: {
                popupContent.position = popupContent.activePlayer.position
                popupContent.length = popupContent.activePlayer.length
            }
        }

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

            // Left arrow - previous player
            Rectangle {
                width: 36
                height: 120
                radius: 10
                color: "transparent"
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 15
                anchors.leftMargin: 5

                Text {
                    anchors.centerIn: parent
                     text: ""
                    color: "white"
                    font.pixelSize: 40
                }

                MouseArea {
                    id: leftArrowMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        const players = Mpris.players.values.filter(p => p.canControl);
                        if (players.length > 0) {
                            let idx = players.indexOf(MprisService.activePlayer);
                            MprisService.setActivePlayer(idx > 0 ? players[idx - 1] : players[players.length - 1]);
                        }
                    }
                }
            }

            // Right arrow - next player
            Rectangle {
                width: 36
                height: 120
                radius: 10
                color: "transparent"
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: 5
                anchors.topMargin: 15

                Text {
                    anchors.centerIn: parent
                    text: ""
                    color: "white"
                    font.pixelSize: 40
                }

                MouseArea {
                    id: rightArrowMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        const players = Mpris.players.values.filter(p => p.canControl);
                        if (players.length > 0) {
                            let idx = players.indexOf(MprisService.activePlayer);
                            MprisService.setActivePlayer(idx < players.length - 1 ? players[idx + 1] : players[0]);
                        }
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: 65
                anchors.rightMargin: 65
                anchors.topMargin: 20
                anchors.bottomMargin: 20
                color: "#02020D"

                // Album art
                Rectangle {
                    id: albumArtContainer
                    width: 80
                    height: 80
                    anchors.top: parent.top
                    anchors.leftMargin: 20
                    radius: 14
                    color: "#1a1a1a"

                    Image {
                        id: img
                        source: MprisService.activeTrack.artUrl
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        smooth: true

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: img.width
                                height: img.height
                                radius: 14
                            }
                        }
                    }
                }

                // Song info
                Column {
                    spacing: 4
                    anchors.left: albumArtContainer.right
                    anchors.leftMargin: 15
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: albumArtContainer.verticalCenter

                    Text {
                        text: MprisService.activeTrack.title
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: "white"
                        width: parent.width
                        elide: Text.ElideRight
                    }

                    Text {
                        text: MprisService.activeTrack.artist
                        color: "#cccccc"
                        font.pixelSize: 16
                        width: parent.width
                        elide: Text.ElideRight
                    }
                }

                // Progress bar and controls
                Column {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: -10
                    spacing: 12
                    width: parent.width - 40
                    opacity: opened ? 1 : 0

                    Behavior on opacity {
                        SequentialAnimation {
                            PauseAnimation { duration: opened ? 350 : 100 }
                            NumberAnimation { duration: opened ? 350 : 100; easing.type: Easing.OutCubic }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: 10

                        Text {
                            text: musicPlayerPopup.formatTime(popupContent.position)
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: "#999"
                            width: 38
                            horizontalAlignment: Text.AlignRight
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Rectangle {
                            id: progressBar
                            width: parent.width - 96
                            height: 6
                            radius: 3
                            color: "#333333"
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                width: parent.width * popupContent.progress
                                height: parent.height
                                radius: parent.radius
                                color: "white"

                                Behavior on width {
                                    NumberAnimation { duration: 200; easing.type: Easing.Linear }
                                }
                            }

                            MouseArea {
                                id: progressMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: function(mouse) {
                                    if (popupContent.activePlayer && popupContent.activePlayer.canSeek && popupContent.length > 0) {
                                        const clickProgress = mouse.x / progressBar.width
                                        const newPosition = clickProgress * popupContent.length
                                        popupContent.activePlayer.position = newPosition
                                    }
                                }
                            }
                        }

                        Text {
                            text: musicPlayerPopup.formatTime(popupContent.length)
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: "#999"
                            width: 38
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Playback controls
                    Row {
                        spacing: 70
                        anchors.horizontalCenter: parent.horizontalCenter

                        Rectangle {
                            width: 44
                            height: 44
                            radius: 10
                            color: "transparent"
                            scale: prevMouse.pressed ? 0.95 : 1

                            Behavior on scale {
                                NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: ""
                                color: "white"
                                font.pixelSize: 35
                            }

                            MouseArea {
                                id: prevMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: MprisService.previous()
                            }
                        }

                        Rectangle {
                            width: 50
                            height: 50
                            radius: 12
                            color: "transparent"
                            scale: playMouse.pressed ? 0.95 : 1

                            Behavior on scale {
                                NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: MprisService.isPlaying ? "" : ""
                                color: "white"
                                font.pixelSize: 50
                            }

                            MouseArea {
                                id: playMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: MprisService.togglePlaying()
                            }
                        }

                        Rectangle {
                            width: 44
                            height: 44
                            radius: 10
                            color: "transparent"
                            scale: nextMouse.pressed ? 0.95 : 1

                            Behavior on scale {
                                NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: ""
                                color: "white"
                                font.pixelSize: 35
                            }

                            MouseArea {
                                id: nextMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: MprisService.next()
                            }
                        }
                    }
                }
            }
        }
    }
}