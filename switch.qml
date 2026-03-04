Rectangle {
    id: toggleThumb

    anchors.fill: parent
    anchors.leftMargin: toggleTrack.isOn ? 0 : 30
    anchors.rightMargin: toggleTrack.isOn ? 30 : 0
    color: toggleTrack.isOn ? "#1F3A2E" : "#E6FFF4"
    radius: 50

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            toggleTrack.isOn = !toggleTrack.isOn;
            moveColorFile("theme1");
            colors.toggleTheme();
        }
    }

    Behavior on anchors.leftMargin {
        NumberAnimation {
            duration: toggleTrack.isOn ? 300 : 100
            easing.type: Easing.InOutQuad
        }

    }

    Behavior on anchors.rightMargin {
        NumberAnimation {
            duration: toggleTrack.isOn ? 100 : 300
            easing.type: Easing.InOutQuad
        }

    }

    Behavior on color {
        ColorAnimation {
            duration: 400
            easing.type: Easing.InOutQuad
        }

    }

}
