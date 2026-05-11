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

    // Fade out the grid, change month, then fade back in
    function switchMonth(newYear, newMonth) {
        fadeOut.targetYear = newYear;
        fadeOut.targetMonth = newMonth;
        fadeOut.start();
    }

    width: 320
    height: 330

    ColorLoader {
        id: colors
    }

    SequentialAnimation {
        id: fadeOut

        property int targetYear
        property int targetMonth

        NumberAnimation {
            target: monthGrid
            property: "opacity"
            to: 0.5
            duration: 300
            easing.type: Easing.InQuad
        }

        ScriptAction {
            script: {
                calendar.currentYear = fadeOut.targetYear;
                calendar.currentMonth = fadeOut.targetMonth;
            }
        }

        NumberAnimation {
            target: monthGrid
            property: "opacity"
            to: 1
            duration: 300
            easing.type: Easing.OutQuad
        }

    }

    Rectangle {
        color: bgPrimary
        radius: 18
        width: 320
        height: 330
        anchors.margins: 0

        // Header with arrows + month name
        Row {
            spacing: 30
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10

            Rectangle {
                width: 35
                height: 25
                radius: 25
                color: leftArrow.containsMouse ? bgSecondaryHover : bgSecondary

                Text {
                    anchors.centerIn: parent
                    text: ""
                    color: bgPrimary
                    font.pixelSize: 20
                }

                MouseArea {
                    id: leftArrow

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (calendar.currentMonth === 0)
                            calendar.switchMonth(calendar.currentYear - 1, 11);
                        else
                            calendar.switchMonth(calendar.currentYear, calendar.currentMonth - 1);
                    }
                }

            }

            Rectangle {
                id: my

                width: 160
                height: 25
                radius: 25
                color: bgSecondary
                layer.enabled: true

                Text {
                    anchors.centerIn: parent
                    text: Qt.formatDate(new Date(calendar.currentYear, calendar.currentMonth, 1), "MMMM yyyy")
                    color: bgPrimary
                    font.pixelSize: 18
                    font.bold: true
                }

            }

            Rectangle {
                width: 35
                height: 25
                radius: 25
                color: rightArrow.containsMouse ? bgSecondaryHover : bgSecondary

                Text {
                    anchors.centerIn: parent
                    text: ""
                    color: bgPrimary
                    font.pixelSize: 20
                }

                MouseArea {
                    id: rightArrow

                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (calendar.currentMonth === 11)
                            calendar.switchMonth(calendar.currentYear + 1, 0);
                        else
                            calendar.switchMonth(calendar.currentYear, calendar.currentMonth + 1);
                    }
                }

            }

        }

        // Weekday names row — fixed width matches grid, centered
        Row {
            width: 294
            spacing: 0
            anchors.top: parent.top
            anchors.topMargin: 48
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

                delegate: Item {
                    width: 294 / 7
                    height: 22

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: bgSecondary
                        font.pixelSize: 13
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                }

            }

        }

        // 7x6 grid of days — anchors.left removed, horizontalCenter only
        Grid {
            id: monthGrid

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 9
            anchors.horizontalCenter: parent.horizontalCenter

            width: 294
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
                            "day": prevMonthDays - (firstDay - i - 1),
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
                    while (days.length < 42)
                        days.push({
                            "day": nextDay++,
                            "inMonth": false,
                            "year": nextYear,
                            "month": nextMonth
                        });
                    return days;
                }

                delegate: Rectangle {
                    // Use integer cell size: (294 - spacing*6) / 7 = 36
                    width: (294 - monthGrid.spacing * 6) / 7
                    height: (294 - monthGrid.spacing * 6) / 7
                    radius: 30
                    color: (modelData.year === calendar.todayYear && modelData.month === calendar.todayMonth && modelData.day === calendar.todayDay)
                           ? bgSecondary
                           : (modelData.inMonth
                              ? (KhalService.hasEventsForDate(new Date(modelData.year, modelData.month, modelData.day)) ? "#4CAF50" : "transparent")
                              : "transparent")

                    Text {
                        anchors.centerIn: parent
                        text: modelData.day
                        opacity: modelData.inMonth ? 1 : 0.4
                        font.pixelSize: 15
                        color: (modelData.year === calendar.todayYear && modelData.month === calendar.todayMonth && modelData.day === calendar.todayDay)
                               ? bgPrimary
                               : bgSecondary
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

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.InOutQuad
            }

        }

    }

}
