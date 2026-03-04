import "../services"
import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell

Item {
    id: calendar

    property int currentYear: new Date().getFullYear()
    property int currentMonth: new Date().getMonth() // 0–11
    property int todayYear: new Date().getFullYear()
    property int todayMonth: new Date().getMonth()
    property int todayDay: new Date().getDate()
    property string bgColor: colors.bgColor
    property string bgPrimary: colors.bgPrimary
    property string bgSecondary: colors.bgSecondary
    property string bgSecondaryHover: colors.bgSecondaryHover
    property string bgPrimaryDark: colors.bgPrimaryDark
    property string bgSecondaryDark: colors.bgSecondaryDark
    property string bgGradient1: colors.bgGradient1
    property string bgGradient2: colors.bgGradient2
    property string bgGradient3: colors.bgGradient3

    

    function daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate();
    }

    function firstDayOfMonth(year, month) {
        return new Date(year, month, 1).getDay(); // 0=Sunday
    }

    width: 320
    height: 330

    ColorLoader {
        id: colors
    }

    Rectangle {
        width: 320
        height: 330
        anchors.centerIn: parent
        radius: 20

        Rectangle {
            color: bgPrimary
            radius: 18
            anchors.fill: parent
            anchors.margins: 0

            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                // Header with arrows + month name
                Row {
                    spacing: 70
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        width: 25
                        height: 25
                        radius: 6
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "‹"
                            color: leftArrow.containsMouse ? bgSecondary : bgSecondaryHover
                            font.pixelSize: 40
                        }

                        MouseArea {
                            id: leftArrow

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (calendar.currentMonth === 0) {
                                    calendar.currentMonth = 11;
                                    calendar.currentYear--;
                                } else {
                                    calendar.currentMonth--;
                                }
                            }
                        }

                    }

                    Item {
                        width: 25
                        height: 25

                        Text {
                            anchors.centerIn: parent
                            text: Qt.formatDate(new Date(calendar.currentYear, calendar.currentMonth, 1), "MMMM yyyy")
                            color: bgSecondary
                            font.pixelSize: 20
                            font.bold: true
                        }

                    }

                    Rectangle {
                        width: 25
                        height: 25
                        radius: 6
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "›"
                            color: rightArrow.containsMouse ? bgSecondary : bgSecondaryHover
                            font.pixelSize: 40
                        }

                        MouseArea {
                            id: rightArrow

                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (calendar.currentMonth === 11) {
                                    calendar.currentMonth = 0;
                                    calendar.currentYear++;
                                } else {
                                    calendar.currentMonth++;
                                }
                            }
                        }

                    }

                }

                // Weekday names row
                Row {
                    width: parent.width
                    spacing: 0

                    Repeater {
                        model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

                        delegate: Item {
                            width: parent.width / 7
                            height: 20

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: bgSecondary
                                font.pixelSize: 12
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                            }

                        }

                    }

                }

                // 7x6 grid of days
                Grid {
                    id: monthGrid

                    width: parent.width
                    columns: 7
                    rows: 6
                    spacing: 6

                    Repeater {
                        id: dayRepeater

                        model: {
                            let days = [];
                            let totalDays = daysInMonth(calendar.currentYear, calendar.currentMonth);
                            let firstDay = firstDayOfMonth(calendar.currentYear, calendar.currentMonth);
                            let prevMonth = (calendar.currentMonth === 0) ? 11 : calendar.currentMonth - 1;
                            let prevYear = (calendar.currentMonth === 0) ? calendar.currentYear - 1 : calendar.currentYear;
                            let prevMonthDays = daysInMonth(prevYear, prevMonth);
                            // Fill blanks with previous month days
                            for (let i = 0; i < firstDay; i++) {
                                days.push({
                                    "day": "",
                                    "inMonth": true,
                                    "year": prevYear,
                                    "month": prevMonth
                                });
                            }
                            // Fill actual days
                            for (let d = 1; d <= totalDays; d++) {
                                days.push({
                                    "day": d,
                                    "inMonth": true,
                                    "year": calendar.currentYear,
                                    "month": calendar.currentMonth
                                });
                            }
                            // Fill remaining blanks with next month days
                            let nextDay = 1;
                            let nextMonth = (calendar.currentMonth === 11) ? 0 : calendar.currentMonth + 1;
                            let nextYear = (calendar.currentMonth === 11) ? calendar.currentYear + 1 : calendar.currentYear;
                            while (days.length < 42)days.push({
                                "day": "",
                                "inMonth": true,
                                "year": nextYear,
                                "month": nextMonth
                            })
                            return days;
                        }

                        delegate: Rectangle {
                            width: (monthGrid.width - (monthGrid.spacing * 6)) / 7
                            height: (monthGrid.width - (monthGrid.spacing * 6)) / 7
                            radius: 30
                            color: (modelData.year === calendar.todayYear && modelData.month === calendar.todayMonth && modelData.day === calendar.todayDay) ? bgSecondary : (modelData.inMonth ? (KhalService.hasEventsForDate(new Date(modelData.year, modelData.month, modelData.day)) ? "#4CAF50" : "transparent") : "transparent")

                            Text {
                                anchors.centerIn: parent
                                text: modelData.day
                                font.pixelSize: 18
                                color: (modelData.year === calendar.todayYear && modelData.month === calendar.todayMonth && modelData.day === calendar.todayDay) ? bgPrimary : (modelData.inMonth ? bgSecondary : "transparent")
                                font.bold: (modelData.year === calendar.todayYear && modelData.month === calendar.todayMonth && modelData.day === calendar.todayDay)
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var d = new Date(modelData.year, modelData.month, modelData.day);
                                    var events = KhalService.getEventsForDate(d);
                                    console.log("Events on", d, events);
                                }
                            }

                        }

                    }

                }

            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.InOutQuad
                }

            }

        }

        gradient: Gradient {
            orientation: Gradient.Vertical

            GradientStop {
                position: 0
                color: bgGradient1

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }

                }

            }

            GradientStop {
                position: 0.7
                color: bgGradient2

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }

                }

            }

            GradientStop {
                position: 1
                color: bgGradient3

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }

                }

            }

        }

    }

}
