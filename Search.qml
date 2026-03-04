import Qt5Compat.GraphicalEffects
import QtQuick 2.15
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
    property string bgGradient1: colors.bgGradient1
    property string bgGradient2: colors.bgGradient2
    property string bgGradient3: colors.bgGradient3
    // List of installed applications
    property var installedApps: []
    property bool isScanning: false
    // Parse desktop files
    property int currentFileIndex: 0
    property var parsedApps: []

    function parseDesktopFiles() {
        currentFileIndex = 0;
        parsedApps = [];
        parseNextFile();
    }

    function parseNextFile() {
        if (currentFileIndex >= desktopFilesProcess.desktopFiles.length) {
            parsedApps.sort((a, b) => {
                return a.name.localeCompare(b.name);
            });
            installedApps = parsedApps;
            console.log(`Loaded ${installedApps.length} applications`);
            isScanning = false;
            return ;
        }
        const filePath = desktopFilesProcess.desktopFiles[currentFileIndex];
        const parser = desktopParserComponent.createObject(root, {
            "filePath": filePath
        });
    }

    function scanApps() {
        isScanning = true;
        desktopFilesProcess.desktopFiles = [];
        installedApps = [];
        desktopFilesProcess.running = true;
    }

    function searchApps(query) {
        if (!query || query.length === 0)
            return installedApps;

        const lowerQuery = query.toLowerCase();
        return installedApps.filter((app) => {
            return app.name.toLowerCase().includes(lowerQuery);
        });
    }

    width: 40
    height: 40
    Component.onCompleted: {
        console.log("Scanning applications...");
        scanApps();
    }

    ColorLoader {
        id: colors
    }

    // Process to find desktop files
    Process {
        id: desktopFilesProcess

        property var desktopFiles: []

        command: ["sh", "-c", "pacman -Qlq | grep '^/usr/share/applications/.*\\.desktop$'"]
        running: false
        onExited: (code, status) => {
            if (code === 0 && desktopFilesProcess.desktopFiles.length > 0) {
                console.log(`Found ${desktopFilesProcess.desktopFiles.length} desktop files, parsing...`);
                parseDesktopFiles();
            } else {
                console.log("Error finding desktop files:", code);
                isScanning = false;
            }
        }

        stdout: SplitParser {
            onRead: (line) => {
                if (line.trim().length > 0)
                    desktopFilesProcess.desktopFiles.push(line.trim());

            }
        }

    }

    Component {
        id: desktopParserComponent

        Process {
            property string filePath
            property var appData: ({
            })

            command: ["sh", "-c", "grep -E '^(Name=|Icon=|Exec=|NoDisplay=)' \"" + filePath + "\" 2>/dev/null"]
            running: true
            onExited: (code, status) => {
                if (appData.name && appData.exec && appData.noDisplay !== "true")
                    parsedApps.push({
                    "name": appData.name,
                    "icon": appData.icon || "",
                    "exec": appData.exec,
                    "desktopFile": filePath
                });

                currentFileIndex++;
                parseNextFile();
                destroy();
            }

            stdout: SplitParser {
                onRead: (line) => {
                    if (line.startsWith("Name=") && !appData.name)
                        appData.name = line.substring(5);
                    else if (line.startsWith("Icon="))
                        appData.icon = line.substring(5);
                    else if (line.startsWith("Exec="))
                        appData.exec = line.substring(5);
                    else if (line.startsWith("NoDisplay="))
                        appData.noDisplay = line.substring(10);
                }
            }

        }

    }

    Rectangle {
        id: topButton

        width: 40
        height: 40
        color: bMouseArea.containsMouse ? bgSecondaryHover : bgPrimary
        radius: 30
        scale: bMouseArea.containsMouse ? 1.15 : 1

        Text {
            text: ""
            anchors.centerIn:parent
            font.pixelSize: 20
            font.bold: true
            color: bMouseArea.containsMouse ? bgPrimary : bgSecondary
        }

        MouseArea {
            id: bMouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                popup.opened = !popup.opened;
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 150
            }

        }

    }

    PopupWindow {
        id: popup

        property bool opened: false

        width: 450
        height: 500
        visible: false
        color: "transparent"

        anchor {
            item: topButton
            edges: Edges.Left | Edges.Top
            rect.y: root.y - 450
        }

        Rectangle {
            id: borderContainer

            width: 450
            height: 500
            radius: 30
            transformOrigin: Item.Bottom
            opacity: popup.opened ? 1 : 0
            scale: popup.opened ? 1 : 0.92

            Rectangle {
                id: popupContent

                anchors.fill: parent
                anchors.margins: 1.3
                color: bgColor
                radius: 28
                layer.enabled: true

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 10

                    

                    Rectangle {
                        width: parent.width
                        height: 40
                        color: bgPrimary
                        radius: 15
                        anchors.horizontalCenter:parent.horizontalCenter

                        TextInput {
                            id: searchInput

                            anchors.fill: parent
                            anchors.margins: 10
                            verticalAlignment: Text.AlignVCenter
                            color: "white"
                            font.pixelSize: 14
                            clip: true
                            selectByMouse: true
                            activeFocusOnPress: true

                            Text {
                                visible: searchInput.text.length === 0
                                text: "Search"
                                color: bgSecondaryDark
                                font.pixelSize:15
                                anchors.verticalCenter: parent.verticalCenter
                            }

                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                searchInput.forceActiveFocus();
                            }
                        }

                    }

                    ListView {
                        width: parent.width
                        height: parent.parent.height - 80
                        clip: true
                        model: searchApps(searchInput.text)
                        spacing: 15
                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 50
                            color: mouseArea.containsMouse ? bgSecondary : "transparent"
                            radius: 15
                            
                            

                            Row {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10
                                
                                Rectangle {
                                    width: 40
                                    height: 40
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: "transparent"
                                    radius: 6
                                    
                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 2
                                        source: modelData.icon ? `image://icon/${modelData.icon}` : ""  
                                        sourceSize: Qt.size(32, 32)
                                        fillMode: Image.PreserveAspectFit
                                        visible: status === Image.Ready
                                    }
                     

                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 52
                                    
                                    Text {
                                        text: modelData.name
                                        color: mouseArea.containsMouse ? bgPrimary : bgSecondary
                                        font.pixelSize: 16
                                        width: parent.width
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: modelData.desktopFile.split('/').pop().replace('.desktop', '')
                                        color: mouseArea.containsMouse ? bgPrimaryDark : bgSecondaryDark
                                        font.pixelSize: 15
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }

                                }

                            }

                            MouseArea {
                                id: mouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    console.log("Launching:", modelData.name);
                                    popup.opened = false;
                                    const launcher = appLaunchComponent.createObject(root, {
                                        "appName": modelData.name,
                                        "execCommand": modelData.exec
                                    });
                                }
                            }

                        }

                    }

                }

                layer.effect: FastBlur {
                    radius: popup.opened ? 0 : 60

                    Behavior on radius {
                        NumberAnimation {
                            duration: 50
                            easing.type: Easing.OutBack
                            easing.overshoot: 0.8
                        }

                    }

                }

            }

            gradient: Gradient {
                orientation: Gradient.Vertical

                GradientStop {
                    position: 0
                    color: bgGradient1
                }

                GradientStop {
                    position: 0.7
                    color: bgGradient2
                }

                GradientStop {
                    position: 1
                    color: bgGradient3
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
                id: slideTransformBorder

                y: popup.opened ? 0 : popupContent.height * 0.3

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
                    // Use a timer to ensure the window is ready
                    focusTimer.start();
                } else {
                    hideTimer.start();
                }
            }

            target: popup
        }

        Timer {
            id: focusTimer

            interval: 100
            repeat: false
            onTriggered: {
                searchInput.forceActiveFocus();
            }
        }

    }

    Component {
        id: appLaunchComponent

        Process {
            property string appName
            property string execCommand

            command: ["sh", "-c", "nohup " + execCommand.replace(/%[a-zA-Z]/g, "").trim() + " >/dev/null 2>&1 &"]
            running: true
            onExited: (code, status) => {
                if (code === 0)
                    console.log("Successfully launched:", appName);
                else
                    console.log("Failed to launch:", appName, "with code:", code);
                destroy();
            }

            stdout: SplitParser {
                onRead: (line) => {
                    console.log("Launch output:", line);
                }
            }

            stderr: SplitParser {
                onRead: (line) => {
                    console.log("Launch error:", line);
                }
            }

        }

    }

}
