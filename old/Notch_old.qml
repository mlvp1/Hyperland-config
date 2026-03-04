import "services"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Io

Item {
    id: notchContainer

    
    ColorLoader {
        id: colors
    }
    property string bgColor: colors.bgColor
    property string bgPrimary: colors.bgPrimary
    property string bgSecondary: colors.bgSecondary
    property string bgSecondaryHover: colors.bgSecondaryHover
    property string bgPrimaryDark: colors.bgPrimaryDark
    property string bgSecondaryDark: colors.bgSecondaryDark


    property bool hasSongPlaying: MprisService.isPlaying && MprisService.activePlayer !== null && MprisService.activeTrack.title !== ""
    property int extendedWidth: 150
    property int normalWidth: bar.width + 40
    
    // changed: base notch width + extra, so when it expands, the volume/song widths also expand
     width: volumeVisible ? normalWidth + 250 : 
           (popup.opened ? popup.expandedWidth : 
           (buttonPopup.opened ? buttonPopup.expandedWidth : 
           (hasSongPlaying ? normalWidth + extendedWidth : normalWidth)))
   
    height: 40

    property bool volumeVisible: false
    property real volumeLevel: 1
    property real lastVolume: volumeLevel
    property bool ok: true
    property real o: 1
    property real o1: 1
    property real animationDuration: 0
    property string iconSource: "icons/sound/volume.png"

   Behavior on width {
        NumberAnimation {
            duration: {
                // Use different durations based on what's changing
                if (volumeVisible) return 300
                if (popup.opened || buttonPopup.opened) return 0
                if (hasSongPlaying) return 300
                return 200
            }
            easing.type: Easing.InOutCubic
        }
    }

    Timer {
        id: volumeHideTimer
        interval: 2000
        repeat: false
        onTriggered: {
            volumeVisible = false
        }
    }

    // Shutdown process
    Process {
        id: shutdownProc

        running: false
        command: ["systemctl", "poweroff"]
    }
    // Shutdown lock
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
    // Volume monitoring process
    Process {
        id: volumeMonitor
        command: ["pactl", "subscribe"]
        running: true
        
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                // Check if the event is related to sink (output device) volume change
                if (data.includes("Event 'change' on sink")) {
                    // Trigger volume update after a small delay to ensure pactl has the latest value
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
                // Parse volume percentage from pactl output
                // Format is like: "Volume: front-left: 65536 / 100% / 0.00 dB"
                const match = data.match(/(\d+)%/)
                if (match && match[1]) {
                    const newVolume = parseInt(match[1]) / 100.0
                    if (Math.abs(newVolume - volumeLevel) > 0.01) {
                        volumeLevel = newVolume
                        playVolumeAnimation()
                        volumeVisible = true
                        volumeHideTimer.restart()
                    }
                }
            }
        }
    }

    Connections {
        target: MprisService

        function onIsPlayingChanged() {
            if (!MprisService.isPlaying)
                animationDuration = 0
        }

        function onActivePlayerChanged() {
            if (!MprisService.isPlaying)
                animationDuration = 0
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

    // Initial volume check on startup
    Component.onCompleted: {
        volumeGetter.running = true
    }

    function updateVolumeIcon() {
        if (volumeLevel === 0) {
            iconSource = "icons/sound/volume-mute.png";
        } else if (volumeLevel < 0.5) {
            iconSource = "icons/sound/volume-off.png";
            if (ok)
                o1 = 1;
            else
                o1 = 0;
        } else if (volumeLevel < 0.7) {
            if (ok)
                o = 1;
            else
                o = 0;
        } else if (volumeLevel > 0.1) {
            iconSource = "icons/sound/volume-off.png";
        }
    }

    function playVolumeAnimation() {
        if (volumeLevel > lastVolume)
            ok = true;
        else if (volumeLevel < lastVolume)
            ok = false;
        lastVolume = volumeLevel;
        updateVolumeIcon();
    }

    // NEW: Expand button positioned to the right of notch
    Rectangle {
        id: expandButton
        width: 40
        height: 40
        radius: 20
        color: expandButtonMouse.containsMouse ? "#1a1a1a" : "#0a0a0a"
        anchors.left: notchCanvas.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        z: 10
        
        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
        
        Text {
            anchors.centerIn: parent
            text: buttonPopup.opened ? "x" : "+"
            color: "white"
            font.pixelSize: 20
            font.bold: true
        }
        
        MouseArea {
            id: expandButtonMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                animationDuration = 450
                buttonPopup.opened = !buttonPopup.opened
                if(!buttonPopup.opened){
                    closeDelayTimer3.start()
                    closeDelayTimer4.start()
                }else{
                    vis2 = true
                    closeDelayTimer3.stop()
                    closeDelayTimer4.stop()
                }
                volumeVisible = false
                popup.opened = false
            }
            
            onEntered: {
                closeDelayTimer3.stop()
                closeDelayTimer4.stop()
            }
            
            onExited: {
                closeDelayTimer3.start()
                animationDuration = 0
            }
        }
    }

    MouseArea {
        id: notchMouseArea
        width: popup.opened ? popup.expandedWidth : (buttonPopup.opened ? buttonPopup.expandedWidth : notchContainer.width)
        height: (popup.opened || buttonPopup.opened) ? notchContainer.height+50 : notchContainer.height
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            animationDuration = 450
            popup.opened = !popup.opened
            if(!popup.opened){
                 closeDelayTimer2.start()
            }else{
                vis=true
                
                closeDelayTimer2.stop()
            }
            volumeVisible = false
            buttonPopup.opened = false
        }

        onExited: {
            closeDelayTimer.start()
            closeDelayTimer2.start()
            closeDelayTimer3.start()
            animationDuration=0

        }
        
        onEntered: {
            closeDelayTimer3.stop()
        }
        
        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0 ) {
                console.log("Scrolled up")
                volumeLevel = Math.min(1.0, volumeLevel + 0.05)
            } else if (wheel.angleDelta.y < 0) {
                console.log("Scrolled down")
                volumeLevel = Math.max(0.0, volumeLevel - 0.05)
            }
           
            animationDuration=0
            volumeVisible = true
            volumeHideTimer.restart()
            playVolumeAnimation()
            updateTimer.restart()
        }
    }
    
    Timer {
        id: closeDelayTimer
        interval: 400
        repeat: false
        onTriggered: {
            if (!popupMouseArea.containsMouse) {
                popup.opened = false
            }
        }
    }
    
    property bool vis: false
    
    Timer {
        id: closeDelayTimer2
        interval: 800
        repeat: false
        onTriggered: {
            if (!popupMouseArea.containsMouse) {
                vis = false
            }
        }
    }
    
    property bool vis2: false
    
    Timer {
        id: closeDelayTimer3
        interval: 400
        repeat: false
        onTriggered: {
            if (!buttonPopupMouseArea.containsMouse && !expandButtonMouse.containsMouse) {
                buttonPopup.opened = false
            }
        }
    }
    
    Timer {
        id: closeDelayTimer4
        interval: 800
        repeat: false
        onTriggered: {
            if (!buttonPopupMouseArea.containsMouse) {
                vis2 = false
            }
        }
    }
    
    function formatTime(seconds) {
        const s = Math.floor(seconds)
        const m = Math.floor(s / 60)
        const sec = s % 60
        return `${m}:${sec.toString().padStart(2, '0')}`
    }

    // Album art on the left when song is playing
    Item {
        id: albumArtNotch
        anchors.left: parent.left
        anchors.top: parent.top
 
        anchors.leftMargin: 10
        anchors.topMargin: 4
        width: 25
        height: 25
        opacity: hasSongPlaying && !volumeVisible && !popup.opened && !buttonPopup.opened ? 1 : 0
        scale: hasSongPlaying && !volumeVisible && !popup.opened && !buttonPopup.opened ? 1 : 0.8
        z: 6
        
        layer.enabled: true
        layer.effect: FastBlur {
            radius: hasSongPlaying && !volumeVisible && !popup.opened && !buttonPopup.opened ? 0 : 50
            Behavior on radius {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.InOutQuad
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: "#1a1a1a"

            Image {
                id: notchAlbumArt
                source: MprisService.activeTrack.artUrl
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                smooth: true
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: notchAlbumArt.width
                        height: notchAlbumArt.height
                        radius: 6
                    }
                }
                MouseArea {
                                    
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MprisService.togglePlaying()
                        }
            }
        }

    
    }
    
    Item {
        id: songIcon
        anchors.right: parent.right
        anchors.top: parent.top
 
        anchors.rightMargin: 10
        anchors.topMargin: 4
        width: 25
        height: 25
        opacity: hasSongPlaying && !volumeVisible && !popup.opened && !buttonPopup.opened ? 1 : 0
        scale: hasSongPlaying && !volumeVisible && !popup.opened && !buttonPopup.opened ? 1 : 0.8
        z: 6
        
        layer.enabled: true
        layer.effect: FastBlur {
            radius: hasSongPlaying && !volumeVisible && !popup.opened && !buttonPopup.opened ? 0 : 50
            Behavior on radius {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.InOutQuad
            }
        }

        AnimatedImage {
            source: "icons/wave.gif"
            width: 25
            height: 25
            playing: true
    
        }
    }

    // Volume icon on the left with stacked images
    Item {
        id: volumeIconContainer
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 20
        width: 100
        height: 24
        opacity: volumeVisible ? 1 : 0
        scale: volumeVisible ? 1 : 0.8
        z: 6
        
        layer.enabled: true
        layer.effect: FastBlur {
            radius: volumeVisible ? 0 : 32
            Behavior on radius {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        Item {
            width: 20
            height: 20
            anchors.verticalCenter: parent.verticalCenter

            // High volume icon (volume.png)
            Image {
                id: volumeIcon
                source: "icons/sound/volume.png"
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
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            // Medium volume icon (volume-down.png)
            Image {
                id: volumeDownIcon
                source: "icons/sound/volume-down.png"
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
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            // Base icon (volume-off.png or volume-mute.png)
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

    Bar {
        id: bar
        anchors.horizontalCenter: parent.horizontalCenter
        y: (popup.opened || volumeVisible || buttonPopup.opened) ? -50 : 5
        z: 5
        opacity: (popup.opened || volumeVisible || buttonPopup.opened) ? 0 : 1
        
        layer.enabled: true
        layer.effect: FastBlur {
            radius: (popup.opened || volumeVisible || buttonPopup.opened) ? 50 : 0
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

    // Volume slider on the right
    Item {
        id: volumeContainer
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 20
        width: 70
        height: 30
        opacity: volumeVisible ? 1 : 0
        scale: volumeVisible ? 1 : 0.8
        z: 6
        
        layer.enabled: true
        layer.effect: FastBlur {
            radius: volumeVisible ? 0 : 32
            Behavior on radius {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
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
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
            }

            MouseArea {
                id: volumeSliderArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                visible:false

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
                    if (pressed)
                        updateVolume(mouse.x);
                }
            }
        }
    }

    // Dynamic Island expanding notch background
    Canvas {
        id: notchCanvas
        anchors.centerIn: parent
        width: popup.opened ? popup.expandedWidth : (buttonPopup.opened ? buttonPopup.expandedWidth : notchContainer.width)
        height: (popup.opened || buttonPopup.opened) ? notchContainer.height+50 : notchContainer.height
        z: (popup.opened || buttonPopup.opened) ? 4 : 0
        
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
        
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            
            var sideRadius = (popup.opened || buttonPopup.opened) ? 0 : 0;
            var bottomRadius = (popup.opened || buttonPopup.opened) ? 10 : 20;
            var topOffset = 0;
            
            var gradient = ctx.createLinearGradient(0, 0, 0, height);
            gradient.addColorStop(0, "#02020D");
            gradient.addColorStop(1, "#02020D");
            
            ctx.fillStyle = gradient;
            ctx.beginPath();
            
            ctx.moveTo(0, topOffset);
            ctx.quadraticCurveTo(sideRadius, topOffset, sideRadius * 2, topOffset + sideRadius);
            ctx.lineTo(sideRadius * 2, height - bottomRadius);
            ctx.arcTo(sideRadius * 2, height, sideRadius * 2 + bottomRadius, height, bottomRadius);
            ctx.lineTo(width - sideRadius * 2 - bottomRadius, height);
            ctx.arcTo(width - sideRadius * 2, height, width - sideRadius * 2, height - bottomRadius, bottomRadius);
            ctx.lineTo(width - sideRadius * 2, topOffset + sideRadius);
            ctx.quadraticCurveTo(width - sideRadius, topOffset, width, topOffset);
            
            ctx.closePath();
            ctx.fill();
        }
    }

    // NEW: Button Panel Popup Window (using same technique as music player)
    PopupWindow {
        id: buttonPopup

        property bool opened: false
        property int expandedWidth: 560
        property int expandedHeight: 150

        width: expandedWidth 
        height: expandedHeight + notchContainer.height 
        visible: vis2
        color: "transparent"

        anchor {
            item: notchContainer
            rect.x: (notchContainer.width / 2 - width / 2)+1
            rect.y: notchContainer.height
        }

        MouseArea {
            id: buttonPopupMouseArea
            anchors.fill: parent
            hoverEnabled: true

            onEntered: {
                closeDelayTimer3.stop()
                closeDelayTimer4.stop()
                animationDuration=0
            }
            
            onExited: {
                closeDelayTimer3.start()
                closeDelayTimer4.start()
                animationDuration = 450
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
            width: buttonPopup.opened ? buttonPopup.expandedWidth : notchContainer.width 
            
            Behavior on width {
                NumberAnimation {
                    duration: animationDuration
                    easing.type: Easing.InOutCubic
                }
            }

            height: buttonPopup.opened ? buttonPopup.expandedHeight : 0
            
            Behavior on height {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.InOutCubic
                }
            }

            Item {
                anchors.fill: parent
                opacity: buttonPopup.opened ? 1 : 0
                scale: buttonPopup.opened ? 1 : 0.8
                
                layer.enabled: true
                layer.effect: FastBlur {
                    radius: buttonPopup.opened ? 0 : 50
                    Behavior on radius {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: buttonPopup.opened ? 150 : 500
                        easing.type: Easing.InOutQuad
                    }
                }
                
                Behavior on scale {
                    NumberAnimation {
                        duration: buttonPopup.opened ? 150 : 200
                        easing.type: Easing.InOutQuad
                    }
                }
                
                Row {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 20
                    
                    // Button 1
                    Rectangle {
                        width: 100
                        height: 100
                        radius: 15
                        color: "#1a1a1a"
    
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: "white"
                            font.pixelSize: 50
                            font.bold: true
                        }
                        
                        MouseArea {
                            id: button1Mouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                              restartProc.running = true;
                            }
                        }
                    }
                    
                    // Button 2
                    Rectangle {
                        width: 100
                        height: 100
                        radius: 15
                        color: "#1a1a1a"
                        
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: "white"
                            font.pixelSize: 50
                            font.bold: true
                        }
                        
                        MouseArea {
                            id: button2Mouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                shutdownProc.running = true;
                            }
                        }
                    }
                    
                    // Button 3
                                 Rectangle {
                        width: 100
                        height: 100
                        radius: 15
                        color: "#1a1a1a"
    
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: "white"
                            font.pixelSize: 50
                            font.bold: true
                        }
                        
                        MouseArea {
                            id: button3Mouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                              lockProc.running = true;
                            }
                        }
                    }
                    
                    // Button 4
                    Rectangle {
                        width: 100
                        height: 100
                        radius: 15
                        color: "#1a1a1a"
    
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "2"
                            color: "white"
                            font.pixelSize: 50
                            font.bold: true
                        }
                        
                        MouseArea {
                            id: button4Mouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                              restartProc.running = true;
                            }
                        }
                    }
                }
            }
        }
    }

    PopupWindow {
        id: popup

        property bool opened: false
        property int expandedWidth: 640
        property int expandedHeight: 200

        width: expandedWidth 
        height: expandedHeight + notchContainer.height 
        visible: vis
        color: "transparent"

        anchor {
            item: notchContainer
            rect.x: (notchContainer.width / 2 - width / 2)+1
            rect.y: notchContainer.height
        }

        MouseArea {
            id: popupMouseArea
            anchors.fill: parent
            hoverEnabled: true
            

            onEntered: {
                closeDelayTimer.stop()
                closeDelayTimer2.stop()
                animationDuration=0
            }
            
            onExited: {
                closeDelayTimer.start()
                closeDelayTimer2.start()
                animationDuration = 450
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
            width: popup.opened ? popup.expandedWidth : notchContainer.width 
            
            Behavior on width {
                NumberAnimation {
                    duration: animationDuration
                    easing.type: Easing.InOutCubic
                }
            }

            height: popup.opened ? popup.expandedHeight : 0
            
            Behavior on height {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.InOutCubic
                }
            }

            Item {
                anchors.fill: parent
                opacity: popup.opened ? 1 : 0
                scale: popup.opened ? 1 : 0.8
                
                layer.enabled: true
                layer.effect: FastBlur {
                    radius: popup.opened ? 0 : 50
                    Behavior on radius {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: popup.opened ? 150 : 500
                        easing.type: Easing.InOutQuad
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: popup.opened ? 150 : 200
                        easing.type: Easing.InOutQuad
                    }
                }
                
                Rectangle {
                    width: 36
                    height: 120
                    radius: 10
                    color: leftArrowMouse.containsMouse ? "transparent" : "transparent"
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: 15
                    anchors.leftMargin: 5
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                            easing.type: Easing.InOutQuad
                        }
                    }

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

                Rectangle {
                    width: 36
                    height: 120
                    radius: 10
                    color: rightArrowMouse.containsMouse ? "transparent" : "transparent"
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.rightMargin: 5
                    anchors.topMargin: 15

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                            easing.type: Easing.InOutQuad
                        }
                    }

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
                    color:"#02020D"
                    
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

                    Column {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: -10
                        spacing: 12
                        width: parent.width - 40
                        opacity: popup.opened ? 1 : 0
                        
                        Behavior on opacity {
                            SequentialAnimation {
                                PauseAnimation { duration: popup.opened ? 350 : 100 }
                                NumberAnimation {
                                    duration: popup.opened ? 350 : 100
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }Row {
                            width: parent.width
                            spacing: 10

                            Text {
                                text: formatTime(popupContent.position)
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
                                height: progressMouse.containsMouse ? 6 : 6
                                radius: 3
                                color: "#333333"
                                anchors.verticalCenter: parent.verticalCenter
                                
                                Behavior on height {
                                    NumberAnimation {
                                        duration: 150
                                        easing.type: Easing.OutQuad
                                    }
                                }

                                Rectangle {
                                    width: parent.width * popupContent.progress
                                    height: parent.height
                                    radius: parent.radius
                                    color: "white"
                                    
                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 200
                                            easing.type: Easing.Linear
                                        }
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
                                text: formatTime(popupContent.length)
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: "#999"
                                width: 38
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            spacing: 70
                            anchors.horizontalCenter: parent.horizontalCenter
           
                            Rectangle {
                                width: 44
                                height: 44
                                radius: 10
                                color: prevMouse.containsMouse ? "transparent" : "transparent"
                                scale: prevMouse.pressed ? 0.95 : 1
                                
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                                
                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 100
                                        easing.type: Easing.OutQuad
                                    }
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
                                color: playMouse.containsMouse ? "transparent" : "transparent"
                                scale: playMouse.pressed ? 0.95 : 1
                                
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                                
                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 100
                                        easing.type: Easing.OutQuad
                                    }
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
                                color: nextMouse.containsMouse ? "transparent" : "transparent"
                                scale: nextMouse.pressed ? 0.95 : 1
                                
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                                
                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 100
                                        easing.type: Easing.OutQuad
                                    }
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
}