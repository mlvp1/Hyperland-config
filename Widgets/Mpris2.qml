import "../services"
import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Item {
    width: 620
    height: 180

    Rectangle {
        id: root
        anchors.fill: parent
        color: "black"
        radius: 16
        border.color: "#2a2a2a"
        border.width: 0

        property real position: activePlayer?.position ?? 0
        property real length: activePlayer?.length ?? 0
        property real progress: length > 0 ? position / length : 0
        property var activePlayer: MprisService.activePlayer

        Timer {
            interval: 500
            repeat: true
            running: MprisService.isPlaying && root.activePlayer
            onTriggered: {
                root.position = root.activePlayer.position
                root.length = root.activePlayer.length
            }
        }

        // Left arrow button
        Rectangle {
            width: 30
            height: 100
            radius: 8
            color: "#2e2e2e"
            border.color: "#444"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10

            Text {
                anchors.centerIn: parent
                text: "◀"
                color: "white"
                font.pixelSize: 18
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    const players = Mpris.players.values.filter(p => p.canControl);
                    if (players.length > 0) {
                        let idx = players.indexOf(MprisService.activePlayer);
                        MprisService.setActivePlayer(idx > 0 ? players[idx - 1] : players[players.length - 1]);
                    }
                }
                onEntered: parent.color = "#444"
                onExited: parent.color = "#2e2e2e"
            }
        }

        // Right arrow button
        Rectangle {
            width: 30
            height: 100
            radius: 8
            color: "#2e2e2e"
            border.color: "#444"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 10

            Text {
                anchors.centerIn: parent
                text: "▶"
                color: "white"
                font.pixelSize: 18
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    const players = Mpris.players.values.filter(p => p.canControl);
                    if (players.length > 0) {
                        let idx = players.indexOf(MprisService.activePlayer);
                        MprisService.setActivePlayer(idx < players.length - 1 ? players[idx + 1] : players[0]);
                    }
                }
                onEntered: parent.color = "#444"
                onExited: parent.color = "#2e2e2e"
            }
        }

        // Center content
        Rectangle {
            color: "transparent"
            anchors.fill: parent
            anchors.leftMargin: 50
            anchors.rightMargin: 50
            anchors.bottomMargin: 60

            // Album art
            Rectangle {
                width: 80
                height: 80
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 50
                radius: 12

                Image {
                    id: img
                    source: MprisService.activeTrack.artUrl
                    width: 80
                    height: 80
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: img.width
                            height: img.height
                            radius: 12
                        }
                    }
                }
            }

            // Track info
            Column {
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 150
                anchors.right: parent.right
                anchors.rightMargin: 10

                Text {
                    text: MprisService.activeTrack.title
                    font.pixelSize: 22
                    font.bold: true
                    color: "white"
                    width: parent.width
                    elide: Text.ElideRight
                }

                Text {
                    text: MprisService.activeTrack.artist
                    color: "#cccccc"
                    font.pixelSize: 16
                    elide: Text.ElideRight
                }

                Text {
                    text: MprisService.activeTrack.album
                    color: "#888"
                    font.pixelSize: 14
                    elide: Text.ElideRight
                }
            }
        }

        // Bottom controls
        Column {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 12
            spacing: 8
            width: parent.width - 120

            // Progress bar
            Row {
                width: parent.width
                spacing: 8

                Text {
                    text: formatTime(root.position)
                    font.pixelSize: 10
                    color: "#888"
                    width: 35
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    id: progressBar
                    width: parent.width - 78
                    height: 4
                    radius: 2
                    color: "#333"
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        width: parent.width * root.progress
                        height: parent.height
                        radius: parent.radius
                        color: "#1db954"
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: function(mouse) {
                            if (root.activePlayer && root.activePlayer.canSeek && root.length > 0) {
                                const clickProgress = mouse.x / progressBar.width
                                const newPosition = clickProgress * root.length
                                root.activePlayer.position = newPosition
                            }
                        }
                        
                        onEntered: progressBar.height = 6
                        onExited: progressBar.height = 4
                    }
                }

                Text {
                    text: formatTime(root.length)
                    font.pixelSize: 10
                    color: "#888"
                    width: 35
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Control buttons
            Row {
                spacing: 80
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 40
                    height: 40
                    radius: 8
                    color: "#2e2e2e"
                    border.color: "#444"

                    Text {
                        anchors.centerIn: parent
                        text: "⏮"
                        color: "white"
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: MprisService.previous()
                        onEntered: parent.color = "#444"
                        onExited: parent.color = "#2e2e2e"
                    }
                }

                Rectangle {
                    width: 40
                    height: 40
                    radius: 8
                    color: "#444"
                    border.color: "#666"

                    Text {
                        anchors.centerIn: parent
                        text: MprisService.isPlaying ? "⏸" : "▶"
                        color: "white"
                        font.pixelSize: 22
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: MprisService.togglePlaying()
                        onEntered: parent.color = "#666"
                        onExited: parent.color = "#444"
                    }
                }

                Rectangle {
                    width: 40
                    height: 40
                    radius: 8
                    color: "#2e2e2e"
                    border.color: "#444"

                    Text {
                        anchors.centerIn: parent
                        text: "⏭"
                        color: "white"
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: MprisService.next()
                        onEntered: parent.color = "#444"
                        onExited: parent.color = "#2e2e2e"
                    }
                }
            }
        }
    }

    function formatTime(seconds) {
        const s = Math.floor(seconds)
        const m = Math.floor(s / 60)
        const sec = s % 60
        return `${m}:${sec.toString().padStart(2, '0')}`
    }
}