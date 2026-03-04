import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io



Window {
    id: widget
    
    width: 400
    height: 500
    color: "#1e1e1e"
    
    property var devices: []
    property string headerInfo: ""
    
    Process {
        id: wpctl
        command: ["wpctl", "status"]
        running: true
        
        stdout: SplitParser {
            onRead: data => parseWpctlOutput(data)
        }
    }
    
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: wpctl.running = true
    }
    
    function parseWpctlOutput(output) {
        devices = []
        var lines = output.split('\n')
        var currentSection = ""
        
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i]
            
            // Parse header (PipeWire info)
            if (line.startsWith("PipeWire")) {
                headerInfo = line
                continue
            }
            
            // Parse sections
            if (line.includes("└─")) {
                currentSection = line.trim().replace("└─ ", "").replace(":", "")
                continue
            }
            
            // Parse device/client entries (look for numbered items)
            var match = line.match(/^\s+(\d+)\.\s+(.+)$/)
            if (match) {
                devices.push({
                    id: match[1],
                    name: match[2].trim(),
                    section: currentSection
                })
            }
        }
        
        devices = devices.slice() // Trigger model update
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10
        
        // Header
        Text {
            text: "PipeWire Devices"
            font.pixelSize: 18
            font.bold: true
            color: "#ffffff"
            Layout.fillWidth: true
        }
        
        Text {
            text: headerInfo
            font.pixelSize: 10
            color: "#aaaaaa"
            Layout.fillWidth: true
            wrapMode: Text.Wrap
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#444444"
        }
        
        // Device List
        ListView {
            id: deviceList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: devices
            spacing: 2
            clip: true
            
            section.property: "section"
            section.criteria: ViewSection.FullString
            section.delegate: Rectangle {
                width: deviceList.width
                height: 30
                color: "#2a2a2a"
                
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    text: section
                    font.bold: true
                    font.pixelSize: 12
                    color: "#00aaff"
                }
            }
            
            delegate: Rectangle {
                width: deviceList.width
                height: 35
                color: index % 2 === 0 ? "#252525" : "#2a2a2a"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 10
                    
                    Rectangle {
                        width: 30
                        height: 20
                        color: "#00aaff"
                        radius: 3
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData.id
                            font.pixelSize: 10
                            font.bold: true
                            color: "#ffffff"
                        }
                    }
                    
                    Text {
                        text: modelData.name
                        font.pixelSize: 11
                        color: "#ffffff"
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }
            }
        }
        
        // Footer
        Text {
            text: "Total: " + devices.length + " devices/clients • Updates every 2s"
            font.pixelSize: 10
            color: "#888888"
            Layout.fillWidth: true
        }
    }
}