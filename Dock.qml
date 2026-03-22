import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import "services"

ShellRoot {
    //   id: grab
    //   windows: [ popup ]
    //   active: true
    // }

    id: shellRoot

    property bool pinned: false
    property var pinnedApps: []
    property string pinnedAppsFile: Quickshell.env("HOME") + "/.config/quickshell/pinned_apps.json"
    property string bgColor: colors.bgColor
    property string bgPrimary: colors.bgPrimary
    property string bgSecondary: colors.bgSecondary
    property string bgSecondaryHover: colors.bgSecondaryHover
    property string bgPrimaryDark: colors.bgPrimaryDark
    property string bgSecondaryDark: colors.bgSecondaryDark
    property string bgGradient1: colors.bgGradient1
    property string bgGradient2: colors.bgGradient2
    property string bgGradient3: colors.bgGradient3
    // FileView to read pinned apps JSON
    property var pinnedAppsReader
    property string jsonToSave: ""
    property string tempFilePath: ""

    function useDefaultApps() {
        pinnedApps = [{
            "appName": "Firefox",
            "iconName": "firefox",
            "command": "firefox"
        }, {
            "appName": "Terminal",
            "iconName": "kitty",
            "command": "kitty"
        }, {
            "appName": "Files",
            "iconName": "org.gnome.Nautilus",
            "command": "nautilus"
        }, {
            "appName": "VS Code",
            "iconName": "visual-studio-code",
            "command": "code"
        }];
        savePinnedApps();
    }

    function loadPinnedApps() {
        // Trigger reload by resetting path
        pinnedAppsReader.path = "";
        pinnedAppsReader.path = pinnedAppsFile;
    }

    function savePinnedApps() {
        var data = {
            "pinnedApps": pinnedApps
        };
        jsonToSave = JSON.stringify(data, null, 2);
        tempFilePath = "/tmp/quickshell_pinned_" + Date.now() + ".json";
        console.log("Saving", pinnedApps.length, "pinned apps to:", pinnedAppsFile);
        // Create directory first
        mkdirComponent.createObject(shellRoot);
    }

    function addPinnedApp(app) {
        // Check if app is already pinned by comparing commands
        for (var i = 0; i < pinnedApps.length; i++) {
            var existingCommand = pinnedApps[i].command.replace(/%[a-zA-Z]/g, "").trim();
            var newCommand = app.exec.replace(/%[a-zA-Z]/g, "").trim();
            if (existingCommand === newCommand) {
                console.log("App already pinned:", app.name);
                return ;
            }
        }
        // Add new pinned app
        var newApp = {
            "appName": app.name,
            "iconName": app.icon || "",
            "command": app.exec.replace(/%[a-zA-Z]/g, "").trim()
        };
        // Create a new array with the added app
        var tempArray = pinnedApps.slice();
        tempArray.push(newApp);
        pinnedApps = tempArray;
        console.log("Added pinned app:", app.name);
        console.log("Total pinned apps:", pinnedApps.length);
        // Save to file
        savePinnedApps();
    }

    function removePinnedApp(index) {
        if (index < 0 || index >= pinnedApps.length) {
            console.log("Invalid index:", index);
            return ;
        }
        var tempArray = pinnedApps.slice();
        var removedApp = tempArray.splice(index, 1)[0];
        pinnedApps = tempArray;
        console.log("Unpinned app:", removedApp.appName);
        console.log("Remaining pinned apps:", pinnedApps.length);
        savePinnedApps();
    }

    Component.onCompleted: {
        console.log("Loading pinned apps from:", pinnedAppsFile);
        loadPinnedApps();
    }

    Component {
        id: mkdirComponent

        Process {
            command: ["mkdir", "-p", Quickshell.env("HOME") + "/.config/quickshell"]
            running: true
            onExited: function(code) {
                console.log("mkdir exit code:", code);
                // Now write the file
                writeTimer.start();
                destroy();
            }
        }

    }

    Timer {
        id: writeTimer

        interval: 50
        repeat: false
        onTriggered: {
            writeFileComponent.createObject(shellRoot);
        }
    }

    Component {
        id: writeFileComponent

        Process {
            property string base64Data: Qt.btoa(shellRoot.jsonToSave)

            command: ["sh", "-c", "echo '" + base64Data + "' | base64 -d > '" + shellRoot.tempFilePath + "' && mv '" + shellRoot.tempFilePath + "' '" + shellRoot.pinnedAppsFile + "'"]
            running: true
            onExited: function(code) {
                if (code === 0)
                    console.log("Successfully saved pinned apps to file");
                else
                    console.log("Error saving pinned apps, exit code:", code);
                destroy();
            }

            stderr: SplitParser {
                onRead: function(line) {
                    console.log("Write error:", line);
                }
            }

        }

    }

    ColorLoader {
        id: colors
    }

    PanelWindow {
        id: dockWindow

        property bool reveal: shellRoot.pinned || dockMouseArea.containsMouse
        property bool exclusiveZoneEnabled: false

        width: dockContainer.width + 40
        height: 70
        color: "transparent"
        exclusiveZone: exclusiveZoneEnabled ? 60 : 0

        anchors {
            bottom: true
        }

        MouseArea {
            id: dockMouseArea

            height: parent.height
            implicitWidth: dockContainer.width + 40
            hoverEnabled: true
            enabled: dockWindow.reveal || anchors.topMargin < dockWindow.height
            z: dockWindow.reveal ? 1 : 0

            anchors {
                top: parent.top
                topMargin: dockWindow.reveal ? 0 : (dockWindow.height - 5)
                horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                id: dockContainer

                width: dockLayout.width + 16
                height: 56
                radius: 30
                color: bgColor
                opacity: dockWindow.reveal ? 1 : 0
                layer.enabled: true

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: 8
                }

                RowLayout {
                    id: dockLayout

                    anchors.centerIn: parent
                    spacing: 5

                    // Search/App Launcher button
                    SearchLauncher {
                        id: searchLauncher

                        onSearchOpened: {
                            shellRoot.pinned = true;
                        }
                    }

                    // Dynamically create pinned app icons
                    Repeater {
                        model: shellRoot.pinnedApps

                        AppIcon {
                            appName: modelData.appName
                            iconName: modelData.iconName
                            command: modelData.command
                            appIndex: index
                        }

                    }

                    // Pin/Unpin toggle button
                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: 40
                        color: pinMouseArea.containsMouse ? bgSecondaryHover : bgPrimary
                        scale: pinMouseArea.containsMouse ? 1.15 : 1

                        Text {
                            anchors.centerIn: parent
                            text: pinned ? "󰐄" : "󰐃"
                            font.pixelSize: 20
                            color: pinMouseArea.containsMouse ? bgPrimary : bgSecondary
                        }

                        MouseArea {
                            id: pinMouseArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                shellRoot.pinned = !shellRoot.pinned;
                                dockWindow.exclusiveZoneEnabled = false;
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }

                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: 150
                            }

                        }

                    }

                    // Exclusive zone toggle button
                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: 40
                        color: ezMouseArea.containsMouse ? bgSecondaryHover : bgPrimary
                        scale: ezMouseArea.containsMouse ? 1.15 : 1

                        Text {
                            anchors.centerIn: parent
                            text: dockWindow.exclusiveZoneEnabled ? "󰍽" : "󰍾"
                            font.pixelSize: 15
                            color: ezMouseArea.containsMouse ? bgPrimary : bgSecondary
                        }

                        MouseArea {
                            id: ezMouseArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                dockWindow.exclusiveZoneEnabled = !dockWindow.exclusiveZoneEnabled;
                                shellRoot.pinned = true;
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }

                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: 150
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

                layer.effect: FastBlur {
                    radius: dockWindow.reveal ? 0 : 32
                    transparentBorder: true

                    Behavior on radius {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }

                    }

                }

            }

            Behavior on anchors.topMargin {
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.OutCubic
                }

            }

        }

    }

    pinnedAppsReader: FileView {
        path: shellRoot.pinnedAppsFile
        onLoaded: {
            try {
                var data = JSON.parse(text());
                if (data.pinnedApps && Array.isArray(data.pinnedApps)) {
                    shellRoot.pinnedApps = data.pinnedApps;
                    console.log("Loaded", shellRoot.pinnedApps.length, "pinned apps from file");
                } else {
                    console.log("No pinnedApps array found, using defaults");
                    useDefaultApps();
                }
            } catch (e) {
                console.error("Failed to parse pinned_apps.json:", e);
                useDefaultApps();
            }
        }
    }
    // HyprlandFocusGrab {

    // Search and App Launcher Component
    component SearchLauncher: Item {
        id: root

        property var installedApps: []
        property bool isScanning: false
        property int currentFileIndex: 0
        property var parsedApps: []

        signal searchOpened()

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
                anchors.centerIn: parent
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
                    shellRoot.pinned = !shellRoot.pinned;
                    if (popup.opened)
                        root.searchOpened();

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

            width: dockContainer.width + 20
            height: 500
            visible: false
            color: "transparent"

            anchor {
                item: topButton
                edges: Edges.Left | Edges.Top
                rect.y: root.y - 448
                rect.x: -4
            }

            Rectangle {
                id: borderContainer

                width: dockContainer.width
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
                            anchors.horizontalCenter: parent.horizontalCenter

                            TextInput {
                                id: searchInput

                                anchors.fill: parent
                                anchors.margins: 10
                                verticalAlignment: Text.AlignVCenter
                                color: "white"
                                font.pixelSize: 14
                                clip: true
                                selectByMouse: true
                                focus: GlobalStates.overviewOpen

                                Text {
                                    visible: searchInput.text.length === 0
                                    text: "Search applications..."
                                    color: bgSecondaryDark
                                    font.pixelSize: 15
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    searchInput.forceActiveFocus();
                                }
                            }

                        }

                        ListView {
                            id: searchListView

                            width: parent.width
                            height: parent.parent.height - 80
                            clip: true
                            model: searchApps(searchInput.text)
                            spacing: 15

                            delegate: Rectangle {
                                id: delegateRect

                                width: ListView.view.width
                                height: 50
                                color: delegateMouseArea.containsMouse ? bgSecondaryHover : "transparent"
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
                                        width: parent.width - 100

                                        Text {
                                            text: modelData.name
                                            color: delegateMouseArea.containsMouse ? bgPrimary : bgPrimary
                                            font.pixelSize: 16
                                            width: parent.width
                                            font.bold: true
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            text: modelData.desktopFile.split('/').pop().replace('.desktop', '')
                                            color: delegateMouseArea.containsMouse ? bgPrimaryDark : bgPrimaryDark
                                            font.pixelSize: 15
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }

                                    }

                                    // Pin button
                                    Rectangle {
                                        width: 30
                                        height: 30
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: pinBtnArea.containsMouse ? bgPrimary : bgSecondary
                                        radius: 15
                                        scale: pinBtnArea.containsMouse ? 1.2 : 1

                                        Text {
                                            anchors.centerIn: parent
                                            text: ""
                                            font.pixelSize: 14
                                            color: pinBtnArea.containsMouse ? bgSecondary : bgPrimary
                                        }

                                        MouseArea {
                                            id: pinBtnArea

                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                console.log("Pin button clicked for:", modelData.name);
                                                shellRoot.addPinnedApp(modelData);
                                                popup.opened = false;
                                            }
                                        }

                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: 300
                                                easing.type: Easing.OutBack
                                                easing.overshoot: 0.5
                                            }

                                        }

                                    }

                                }

                                MouseArea {
                                    id: delegateMouseArea

                                    anchors.fill: parent
                                    anchors.rightMargin: 40
                                    hoverEnabled: true
                                    onClicked: {
                                        console.log("Launching:", modelData.name);
                                        popup.opened = false;
                                        var cleanCommand = modelData.exec.replace(/%[a-zA-Z]/g, "").trim();
                                        Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "' + cleanCommand + ' &"]; running: true }', root);
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

    }

    // Reusable app icon component
    component AppIcon: Item {
        id: iconButton

        property string appName: ""
        property string iconName: ""
        property string command: ""
        property int appIndex: -1

        Layout.preferredWidth: 48
        Layout.preferredHeight: 48
        scale: mouseArea.containsMouse ? 1.15 : 1

        Rectangle {
            id: iconBg

            anchors.fill: parent
            radius: 8
            color: "transparent"
            anchors.bottomMargin: mouseArea.containsMouse ? 10 : 0

            Image {
                id: iconImage

                anchors.centerIn: parent
                width: 35
                height: 35
                source: "image://icon/" + iconButton.iconName
                sourceSize: Qt.size(40, 40)
                asynchronous: true

                Rectangle {
                    anchors.fill: parent
                    visible: iconImage.status === Image.Error || iconImage.status === Image.Null
                    radius: 6
                    color: "#3498db"

                    Text {
                        anchors.centerIn: parent
                        text: iconButton.appName.charAt(0)
                        font.pixelSize: 20
                        font.bold: true
                        color: "white"
                    }

                }

            }

            MouseArea {
                id: mouseArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        console.log("Launching:", iconButton.command);
                        Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "' + iconButton.command + ' &"]; running: true }', iconButton);
                    } else if (mouse.button === Qt.RightButton) {
                        console.log("Right-click to unpin at index:", iconButton.appIndex);
                        shellRoot.removePinnedApp(iconButton.appIndex);
                    }
                }
            }

            Behavior on anchors.bottomMargin {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }

            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 150
            }

        }

    }

}
