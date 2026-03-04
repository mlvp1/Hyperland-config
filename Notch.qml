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
    id: notchContainer
    
    property string bgColor: colors.bgColor
    property string bgPrimary: colors.bgPrimary
    property string bgSecondary: colors.bgSecondary
    property string bgSecondaryHover: colors.bgSecondaryHover
    property string bgPrimaryDark: colors.bgPrimaryDark
    property string bgSecondaryDark: colors.bgSecondaryDark
    property bool hasSongPlaying: MprisService.isPlaying && MprisService.activePlayer !== null && MprisService.activeTrack.title !== ""
    property int extendedWidth: 150
    property int normalWidth: bar.width + 40
    property real animationDuration: 0
    
    width: volumeModule.visible ? normalWidth + 250 : (musicPlayer.opened ? musicPlayer.expandedWidth : (buttonPanel.opened ? buttonPanel.expandedWidth : (hasSongPlaying ? normalWidth + extendedWidth : normalWidth)))
    height: 40
    
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
    
    // Now Playing Song Info
    NowPlayingNotch {
        id: nowPlaying
        anchors.fill: parent
        visible: hasSongPlaying && !volumeModule.visible && !musicPlayer.opened && !buttonPanel.opened
        z: 5
    }
    
    // Volume Module
    VolumeModule {
        id: volumeModule
        anchors.fill: parent
        visible: false // DEFAULT TO HIDDEN - Bar shows first
        z: 5
        
        onVisibleChanged: {
            if (visible) {
                musicPlayer.opened = false;
                buttonPanel.opened = false;
            }
        }
    }
    
    //Bar
    Bar {
        id: bar
        anchors.horizontalCenter: parent.horizontalCenter
        y: (musicPlayer.opened || volumeModule.visible || buttonPanel.opened) ? -50 : 5
        z: 5
        opacity: (musicPlayer.opened || volumeModule.visible || buttonPanel.opened) ? 0 : 1
        layer.enabled: true
        layer.effect: FastBlur {
            radius: (musicPlayer.opened || volumeModule.visible || buttonPanel.opened) ? 50 : 0
            
            Behavior on radius {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }
        
        Behavior on y {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutCubic
            }
        }
        
        Behavior on opacity {
            NumberAnimation {
                duration: 100
                easing.type: Easing.InOutCubic
            }
        }
    }
    
    // Main notch background
    Canvas {
        id: notchCanvas
        anchors.centerIn: parent
        width: musicPlayer.opened ? musicPlayer.expandedWidth : (buttonPanel.opened ? buttonPanel.expandedWidth: notchContainer.width )
        height: (musicPlayer.opened || buttonPanel.opened) ? notchContainer.height + 50 : notchContainer.height
        z: (musicPlayer.opened || buttonPanel.opened) ? 4 : 0
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 4
            radius: 16
            samples: 33
            color: "#80000000"
            transparentBorder: true
        }
        
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            var plus=(musicPlayer.opened || buttonPanel.opened) ? 0 : 0;
            var sideRadius = (musicPlayer.opened || buttonPanel.opened) ? 0 : 0;
            var bottomRadius = 20;
            var topOffset = -2;
            var gradient = ctx.createLinearGradient(0, 0, 0, height);
            gradient.addColorStop(0, "#02020D");
            gradient.addColorStop(1, "#02020D");
            ctx.fillStyle = gradient;
            ctx.beginPath();
            ctx.moveTo(0, topOffset);
            ctx.quadraticCurveTo(sideRadius+plus, topOffset, sideRadius * 2, topOffset + sideRadius);
            ctx.lineTo(sideRadius * 2, height - bottomRadius);
            ctx.arcTo(sideRadius * 2, height, sideRadius * 2 + bottomRadius, height, bottomRadius);
            ctx.lineTo(width - sideRadius * 2 - bottomRadius, height);
            ctx.arcTo(width - sideRadius * 2, height, width - sideRadius * 2, height - bottomRadius, bottomRadius);
            ctx.lineTo(width - sideRadius * 2, topOffset + sideRadius);
            ctx.quadraticCurveTo((width - sideRadius)-plus, topOffset, width, topOffset);
            ctx.closePath();
            ctx.fill();
        }
        
        Behavior on width {
            NumberAnimation {
                duration: animationDuration
                easing.type: Easing.InOutCubic
            }
        }
        
        Behavior on height {
            NumberAnimation {
                duration: 400
                easing.type: Easing.InOutCubic
            }
        }
    }
    
    Rectangle {
        width: 45
        height: 30
        radius: 20
        color: buttonMouseArea.containsMouse? bgSecondaryHover: bgPrimary
        anchors.left: notchMouseArea.left
        anchors.top: notchMouseArea.top
        anchors.leftMargin:-50
        anchors.topMargin:8
        
        Text{
            text:buttonPanel.opened? "⏻" : "⏻"
            anchors.centerIn:parent
            font.bold:true
            font.pixelSize:25
            color: buttonMouseArea.containsMouse? bgPrimary: bgSecondaryHover
        }
        
        MouseArea {
            id: buttonMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            onClicked: {
                animationDuration = 0;
                buttonPanel.opened = !buttonPanel.opened;
            }
        }
    }
    
    // Main notch mouse area for music player
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
            musicPlayer.stopCloseTimer();
            buttonPanel.stopCloseTimer();
        }
        
        onWheel: (wheel) => {
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
            duration: {
                if (volumeModule.visible)
                    return 300;
                if (musicPlayer.opened || buttonPanel.opened)
                    return 450;
                if (hasSongPlaying)
                    return 300;
                return 50;
            }
            easing.type: Easing.InOutCubic
        }
    }
}