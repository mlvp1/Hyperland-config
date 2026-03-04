import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "Widgets"
import "services"

PanelWindow {
    width:500
    height:100
    Column {
        spacing: 10

        Text {
            text: "Themes"
            font.pixelSize: 18
        }

        Repeater {
            model: ColorPalette.themes

            Button {
                text: modelData.split("/").pop().replace(".json", "")
                width: 200
                onClicked: ColorPalette.applyTheme(modelData)
            }

        }

    }

}
