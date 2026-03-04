import "../services" // assuming KhalService.qml is in services/
import QtQuick
import Quickshell

Item {
    id: calendar

    property int currentYear: new Date().getFullYear()
    property int currentMonth: new Date().getMonth() // 0–11
    property int todayYear: new Date().getFullYear()
    property int todayMonth: new Date().getMonth()
    property int todayDay: new Date().getDate()

    function daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate();
    }

    function firstDayOfMonth(year, month) {
        return new Date(year, month, 1).getDay(); // 0=Sunday
    }

    width: 420
    height: 420

    Rectangle {
        anchors.fill: parent
        color: "#222"
        radius: 20
        border.color: "#444"

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            // Header with arrows + month name
            Row {
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 30
                    height: 30
                    radius: 6
                    color: "#444"

                    Text {
                        anchors.centerIn: parent
                        text: "◀"
                        color: "white"
                    }

                    MouseArea {
                        anchors.fill: parent
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

                Text {
                    text: Qt.formatDate(new Date(calendar.currentYear, calendar.currentMonth, 1), "MMMM yyyy")
                    color: "white"
                    font.pixelSize: 18
                    font.bold: true
                }

                Rectangle {
                    width: 30
                    height: 30
                    radius: 6
                    color: "#444"

                    Text {
                        anchors.centerIn: parent
                        text: "▶"
                        color: "white"
                    }

                    MouseArea {
                        anchors.fill: parent
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
                spacing: 4
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

                    delegate: Text {
                        width: 50
                        height: 20
                        text: modelData
                        color: "#bbb"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                    }

                }

            }

            // 7x6 grid of days
            Grid {
                id: monthGrid

                columns: 7
                rows: 6
                spacing: 4
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    // Color for today (deepskyblue)

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
                                "day": prevMonthDays - firstDay + i + 1,
                                "inMonth": false,
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
                            "day": nextDay++,
                            "inMonth": false,
                            "year": nextYear,
                            "month": nextMonth
                        })
                        return days;
                    }

                    delegate: Rectangle {
                        width: 50
                        height: 50
                        radius: 6
                        color: (modelData.year === calendar.todayYear && modelData.month === calendar.todayMonth && modelData.day === calendar.todayDay) ? "#1E90FF" : (modelData.inMonth ? (KhalService.hasEventsForDate(new Date(modelData.year, modelData.month, modelData.day)) ? "#4CAF50" : "#333") : "#2a2a2a")

                        Text {
                            font.pixelSize: 18
                            anchors.centerIn: parent
                            text: modelData.day
                            color: modelData.inMonth ? "white" : "#777"
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

    }

}
