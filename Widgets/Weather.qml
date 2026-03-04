import QtQuick
import Quickshell
import Quickshell.Io

PanelWindow {
    width: 220
    height: 120

    // Weather service logic
    Item {
        id: weather

        readonly property var weatherIcons: ({
            "113": "☀️", "116": "⛅", "119": "☁️", "122": "☁️",
            "143": "🌫️", "176": "🌦️", "179": "🌧️", "182": "🌧️",
            "200": "⛈️", "227": "🌨️", "230": "❄️", "248": "🌫️",
            "260": "🌫️", "263": "🌧️", "266": "🌧️", "302": "❄️",
            "308": "❄️", "320": "🌨️", "329": "❄️", "332": "❄️",
            "335": "❄️", "338": "❄️", "359": "❄️", "371": "❄️",
            "389": "⛈️", "395": "❄️"
        })

        property string location: "Tunis"
        property string icon: ""
        property string desc: ""
        property string temp: ""

        function getWeatherIcon(code) {
            return weatherIcons.hasOwnProperty(code) ? weatherIcons[code] : "🍃"
        }

        function reload() {
            Requests.get(`https://wttr.in/${location}?format=j1`, text => {
                const json = JSON.parse(text).current_condition[0]
                icon = getWeatherIcon(json.weatherCode)
                desc = json.weatherDesc[0].value
                temp = `${parseFloat(json.temp_C)}°C`
            })
        }

        Component.onCompleted: reload()

        Timer {
            interval: 60000
            running: true
            repeat: true
            onTriggered: weather.reload()
        }
    }

    // UI
    Rectangle {
        anchors.fill: parent
        radius: 12
        color: "#1e1e1e"
        border.color: "#333"
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: weather.location
                font.pixelSize: 16
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }

            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: weather.icon
                    font.pixelSize: 28
                }

                Text {
                    text: weather.temp
                    font.pixelSize: 20
                    color: "#79AE65"
                }
            }

            Text {
                text: weather.desc
                font.pixelSize: 14
                color: "#bbb"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }
    }
}
