import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root
    
    property string colorsJsonFilePath: Quickshell.env("HOME") + "/.config/quickshell/themes/colors.json"
    
    // Declare the color properties
    property string bgColor: "#1D1433"
    property string bgPrimary: "#4F378B"
    property string bgSecondary: "#F6EFFF"
    property string bgPrimaryDark: "#1D1433"
    property string bgSecondaryDark: "#D2C7E5"
    property string bgSecondaryHover: "#EADDFF"
    property string bgGradient1: "#6E5AB0"
    property string bgGradient2: "#4F378B"
    property string bgGradient3: "#35225E"
    
    // FileView to read the colors.json file
    property var colorReader
    colorReader: FileView {
        path: root.colorsJsonFilePath
        
        onLoaded: {
            try {
                var data = JSON.parse(text());
                if (data.dark) {
                    root.bgColor = data.dark.bg;
                    root.bgPrimary = data.dark.Primary;
                    root.bgSecondary = data.dark.Secondary;
                    root.bgPrimaryDark = data.dark.PrimaryDark;
                    root.bgSecondaryDark = data.dark.SecondaryDark;
                    root.bgSecondaryHover = data.dark.SecondaryHover;
                    root.bgGradient1 = data.dark.Gradient1;
                    root.bgGradient2 = data.dark.Gradient2;
                    root.bgGradient3 = data.dark.Gradient3;
                }
      
            } catch (e) {
                console.error("Failed to parse colors.json:", e);
            }
        }
    }
    
    // Timer to periodically reload colors
    property var reloadTimer
    reloadTimer: Timer {
        interval: 10  
        running: true
        repeat: true
        
        onTriggered: {
            root.loadColors();
        }
    }
    
    // Helper function to add transparency to any color
    function withAlpha(color, alpha) {
        return color + alpha;
    }
    
    // Load colors from JSON file
    function loadColors() {
        colorReader.path = "";
        colorReader.path = colorsJsonFilePath;
    }
    
    // Initialize on creation
    Component.onCompleted: {
        loadColors();
    }
}