import "NotchModules"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
// NotchContainer.qml
import "services"

Item {
    // Main notch background — improved canvas rendering

    id: notchContainer

    property string bgColor: colors.bgColor
    property string bgPrimary: colors.bgPrimary
    property string bgSecondary: colors.bgSecondary
    property string bgSecondaryHover: colors.bgSecondaryHover
    property string bgPrimaryDark: colors.bgPrimaryDark
    property string bgSecondaryDark: colors.bgSecondaryDark
    property bool hasSongPlaying: MprisService.isPlaying && MprisService.activePlayer !== null && MprisService.activeTrack.title !== ""
    property int extendedWidth: 150
    property int normalWidth: bar.width + 50
    property real animationDuration: 0

    width: volumeModule.visible ? normalWidth + 250 : (musicPlayer.opened ? musicPlayer.expandedWidth : (buttonPanel.opened ? buttonPanel.expandedWidth : (hasSongPlaying ? normalWidth + extendedWidth : normalWidth)))
    height: 40
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter

    IpcHandler {
        function toggleButtonPanel() {
            animationDuration = 0;
            buttonPanel.opened = !buttonPanel.opened;
        }

        function toggleMusicPanel() {
            animationDuration = 0;
            musicPlayer.opened = !musicPlayer.opened;
            if (musicPlayer.opened) {
                volumeModule.visible = false;
                buttonPanel.opened = false;
            }
        }

        target: "notch"
    }

    ColorLoader {
        id: colors
    }

    Connections {
        function onIsPlayingChanged() {
            if (!MprisService.isPlaying)
                animationDuration = 0;

        }

        function onActivePlayerChanged() {
            if (!MprisService.isPlaying)
                animationDuration = 0;

        }

        target: MprisService
    }

    Rectangle {
        id: notchCanvas

        anchors.horizontalCenter: parent.horizontalCenter
     anchors.top:parent.top
     anchors.topMargin:1
        width: notchMouseArea.containsMouse && !musicPlayer.opened && !buttonPanel.opened ? notchContainer.width : musicPlayer.opened ? musicPlayer.expandedWidth + 2 : (buttonPanel.opened ? buttonPanel.expandedWidth : notchContainer.width)
        height: notchMouseArea.containsMouse && !musicPlayer.opened && !buttonPanel.opened ? notchContainer.height - 2 : (musicPlayer.opened || buttonPanel.opened) ? notchContainer.height + 100 : notchContainer.height - 2
        layer.enabled: true
        color: "#02020D"
        radius: (musicPlayer.opened || buttonPanel.opened) ? 50 : 20

        NowPlayingNotch {
            id: nowPlaying

            size:0.9
            anchors.fill: parent
            anchors.horizontalCenter: parent.horizontalCenter
            visible: hasSongPlaying && !volumeModule.visible && !buttonPanel.opened
            z: 5
            opacity: musicPlayer.opened ? 0 : 1
            anchors.topMargin: musicPlayer.opened ? 20 : 0
            layer.enabled: true

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.InOutCubic
                }

            }

            Behavior on anchors.topMargin {
                NumberAnimation {
                    duration: 280
                    easing.type: Easing.InOutCubic
                }

            }

            layer.effect: FastBlur {
                radius: (musicPlayer.opened || volumeModule.visible || buttonPanel.opened) ? 48 : 0

                Behavior on radius {
                    NumberAnimation {
                        duration: 280
                        easing.type: Easing.InOutQuad
                    }

                }

            }

        }

        // Volume Module
        VolumeModule {
            id: volumeModule

            anchors.fill: parent
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false
            z: 5
            onVisibleChanged: {
                if (visible) {
                    musicPlayer.opened = false;
                    buttonPanel.opened = false;
                }
            }
        }

        // Main notch mouse area
        MouseArea {
            id: notchMouseArea

            width: musicPlayer.opened ? musicPlayer.expandedWidth : (buttonPanel.opened ? buttonPanel.expandedWidth : notchContainer.width)
            height: (musicPlayer.opened || buttonPanel.opened) ? notchContainer.height + 50 : notchContainer.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                animationDuration = 0;
                musicPlayer.opened = !musicPlayer.opened;
                if (musicPlayer.opened) {
                    volumeModule.visible = false;
                    buttonPanel.opened = false;
                }
            }
            onExited: {
                musicPlayer.startCloseTimer();
                animationDuration = 0;
            }
            onEntered: {
                animationDuration = 0;
                musicPlayer.stopCloseTimer();
                buttonPanel.stopCloseTimer();
            }
            onWheel: (wheel) => {
                animationDuration = 0;
                volumeModule.handleWheel(wheel);
            }
        }

        // Music Player Popup
        MusicPlayerPopup {
            id: musicPlayer

            notchItem: notchContainer
            onOpenedChanged: {
                if (opened)
                    animationDuration = 450;

            }

            anchor {
                item: notchItem
                rect.x: (notchItem.width / 2 - width / 2)
                rect.y: notchItem.height - 0
            }

        }

        // Button Panel Popup
        ButtonPanelPopup {
            id: buttonPanel

            notchItem: notchContainer
            onOpenedChanged: {
                if (opened)
                    animationDuration = 450;

            }
        }

        Behavior on width {
            NumberAnimation {
                duration: animationDuration
                easing.type: Easing.InOutCubic
            }

        }

        Behavior on radius {
            NumberAnimation {
                duration: 400
                easing.type: Easing.InOutCubic
            }

        }

        Behavior on height {
            NumberAnimation {
                duration: (musicPlayer.opened || buttonPanel.opened) ? 480 : animationDuration
                easing.type: Easing.InOutCubic
            }

        }

    }

    Bar {
        id: bar

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: (musicPlayer.opened || volumeModule.visible || buttonPanel.opened) ? -55 : 0
        z: 5
        opacity: (musicPlayer.opened || volumeModule.visible || buttonPanel.opened) ? 0 : 1
        layer.enabled: true

        MouseArea {
            id: barM

            anchors.fill: parent
            hoverEnabled: true
        }

        layer.effect: FastBlur {
            radius: (musicPlayer.opened || volumeModule.visible || buttonPanel.opened) ? 48 : 0

            Behavior on radius {
                NumberAnimation {
                    duration: 320
                    easing.type: Easing.InOutQuad
                }

            }

        }

        Behavior on anchors.verticalCenterOffset {
            NumberAnimation {
                duration: 320
                easing.type: Easing.InOutCubic
            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: 120
                easing.type: Easing.InOutCubic
            }

        }

    }

    Behavior on width {
        NumberAnimation {
            duration: {
                if (volumeModule.visible)
                    return 300;

                if (musicPlayer.opened || buttonPanel.opened)
                    return 450;

                if (hasSongPlaying)
                    return 320;

                return 300;
            }
            easing.type: Easing.InOutCubic
        }

    }

}
