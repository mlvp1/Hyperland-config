import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import "services"

Column {
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

    ColorLoader { id: colors }

    // Tracks which app groups are already visible so Repeater rebuilds
    // don't replay the appear animation on existing delegates.
    property var seenGroups: ({})

    anchors.fill: parent
    anchors.topMargin:10 

    width: 380
    height: popupColumn.implicitHeight

    Column {
        id: popupColumn
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 8
        width: parent.width

        Repeater {
            model: Notifications.popupAppNameList

            delegate: NotificationGroup {
                required property string modelData
                appName: modelData
                notifications: Notifications.popupGroupsByAppName[modelData]?.notifications ?? []
                width: popupColumn.width
            }
        }
    }

    // ── Notification group card ───────────────────────────────────────────────
    component NotificationGroup: Item {
        id: groupRoot
        required property string appName
        required property list<var> notifications

        property bool dismissed: false
        property real dragOffset: 0

        // The card starts translated right + invisible, then animates in.
        // We drive position manually so drag + animations don't conflict.
        // Start at correct state immediately — no flicker on first frame
        property real animX: root.seenGroups[appName] ? 0 : 60
        property real animOpacity: root.seenGroups[appName] ? 1 : 0

        implicitHeight: innerCol.implicitHeight + 24
        // Collapse height to 0 once leaving; Behavior smooths it
        property bool isLeaving: false
        height: isLeaving ? 0 : implicitHeight
        clip: true
        Behavior on height {
            NumberAnimation { duration: 220; easing.type: Easing.InOutCubic }
        }

        // Single transform so drag and slide share the same translate
        transform: Translate { x: groupRoot.animX + groupRoot.dragOffset }
        opacity: groupRoot.animOpacity

        // ── Appear ────────────────────────────────────────────────────────────
        // seenGroups persists on root across Repeater rebuilds.
        // New group → animate in. Existing group being rebuilt → snap to visible.
        Component.onCompleted: {
            if (root.seenGroups[appName]) {
                animX = 0
                animOpacity = 1
            } else {
                root.seenGroups[appName] = true
                appearAnim.start()
            }
        }

        Component.onDestruction: {
            if (dismissed) {
                var copy = root.seenGroups
                delete copy[appName]
                root.seenGroups = copy
            }
        }

        ParallelAnimation {
            id: appearAnim
            NumberAnimation {
                target: groupRoot; property: "animOpacity"
                from: 0; to: 1
                duration: 280; easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: groupRoot; property: "animX"
                from: 60; to: 0
                duration: 300; easing.type: Easing.OutExpo
            }
        }

        // ── Dismiss ───────────────────────────────────────────────────────────
        property var pendingIds: []

        function dismiss(ids) {
            if (dismissed) return
            dismissed = true
            pendingIds = ids || []
            dismissAnim.start()
        }

        SequentialAnimation {
            id: dismissAnim
            ParallelAnimation {
                NumberAnimation {
                    target: groupRoot; property: "animOpacity"
                    to: 0; duration: 180; easing.type: Easing.InCubic
                }
                NumberAnimation {
                    target: groupRoot; property: "animX"
                    to: 60; duration: 200; easing.type: Easing.InExpo
                }
            }
            ScriptAction {
                script: {
                    groupRoot.isLeaving = true
                    groupRoot.pendingIds.forEach(function(id) {
                        Notifications.discardNotification(id)
                    })
                }
            }
        }

        // ── Fling ─────────────────────────────────────────────────────────────
        function fling(direction, ids) {
            if (dismissed) return
            dismissed = true
            pendingIds = ids || []
            flingAnim.targetX = direction > 0 ? 500 : -500
            flingAnim.start()
        }

        SequentialAnimation {
            id: flingAnim
            property real targetX: 500
            ParallelAnimation {
                NumberAnimation {
                    target: groupRoot; property: "dragOffset"
                    to: flingAnim.targetX; duration: 220; easing.type: Easing.OutExpo
                }
                NumberAnimation {
                    target: groupRoot; property: "animOpacity"
                    to: 0; duration: 180; easing.type: Easing.InCubic
                }
            }
            ScriptAction {
                script: {
                    groupRoot.isLeaving = true
                    groupRoot.pendingIds.forEach(function(id) {
                        Notifications.discardNotification(id)
                    })
                }
            }
        }

        // Auto-dismiss when service removes notifications
        onNotificationsChanged: {
            if (notifications.length === 0 && !dismissed) {
                dismissed = true
                dismissAnim.start()
                // Nothing to discard — service already did it
            }
        }

        // ── Card ──────────────────────────────────────────────────────────────
        Rectangle {
            id: card
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            implicitHeight: innerCol.implicitHeight + 24
            height: implicitHeight
            radius: 14
            color: bgColor
            border.color: Qt.rgba(1, 1, 1, 0.07)
           

  
ColumnLayout {
    id: innerCol
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.margins: 12
    spacing: 6

    layer.enabled: true
    layer.effect: FastBlur {
        radius: innerCol.blurRadius
    }

    property real blurRadius: 40  // starts blurry

    // Kick off the blur-clear when the card appears
    Component.onCompleted: blurInAnim.start()

    NumberAnimation {
        id: blurInAnim
        target: innerCol
        property: "blurRadius"
        from: 40
        to: 0
        duration: 450
        easing.type: Easing.OutCubic
    }
                // Header row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Item {
                        width: 20; height: 20
                        Rectangle {
                            anchors.fill: parent; radius: 6
                            color: bgPrimaryDark
                            visible: appIcon.status !== Image.Ready
                        }
                        Image {
                            id: appIcon
                            anchors.fill: parent
                            source: {
                                const icon = groupRoot.notifications[0]?.appIcon ?? ""
                                if (!icon) return ""
                                if (icon.startsWith("/") || icon.startsWith("file://") || icon.startsWith("http"))
                                    return icon
                                return "image://icon/" + icon
                            }
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }
                    }

                    Text {
                        text: groupRoot.appName || "Notification"
                        font.pixelSize: 11; font.weight: Font.Medium
                        font.family: "Rubik"
                        color: bgPrimary
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: formatTime(groupRoot.notifications[0]?.time ?? 0)
                        font.pixelSize: 10; font.family: "Rubik"
                        color: bgPrimary
                    }

                    // Close button
                    Item {
                        width: 20; height: 20
                        Rectangle {
                            anchors.fill: parent; radius: 10
                            color: closeHover.containsMouse ? Qt.rgba(1,1,1,0.15) : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }
                        Text {
                            anchors.centerIn: parent
                            text: "✕"; font.pixelSize: 10
                            color: bgPrimary
                        }
                        
                        HoverHandler { id: closeHover  }
                        TapHandler {
                            onTapped: {
                                
                                const ids = groupRoot.notifications.map(function(n) {
                                    return n.notificationId
                                })
                                groupRoot.dismiss(ids)
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true; height: 1
                    color: Qt.rgba(1, 1, 1, 0.06)
                }

                Repeater {
                    model: groupRoot.notifications
                    delegate: NotificationRow {
                        required property var modelData
                        notif: modelData
                        Layout.fillWidth: true
                    }
                }

                Item { height: 4 }
            }

            // Drag
            DragHandler {
                id: dragger
                xAxis.enabled: true
                yAxis.enabled: false
                enabled: !groupRoot.dismissed

                property real pressX: 0

                onGrabChanged: function(transition, point) {
                    if (transition === PointerDevice.GrabExclusive) {
                        pressX = point.scenePosition.x
                    }
                }

                onCentroidChanged: {
                    if (active && !groupRoot.dismissed) {
                        groupRoot.dragOffset = centroid.scenePosition.x - pressX
                    }
                }

                onActiveChanged: {
                    if (!active) {
                        const dx = groupRoot.dragOffset
                        if (Math.abs(dx) > 100) {
                            const ids = groupRoot.notifications.map(function(n) {
                                return n.notificationId
                            })
                            groupRoot.fling(dx, ids)
                        } else {
                            snapBack.start()
                        }
                    }
                }
            }
        }

        NumberAnimation {
            id: snapBack
            target: groupRoot; property: "dragOffset"
            to: 0; duration: 260
            easing.type: Easing.OutBack; easing.overshoot: 0.5
        }
    }

    // ── Notification row ──────────────────────────────────────────────────────
    component NotificationRow: ColumnLayout {
        id: rowRoot
        required property var notif
        spacing: 3

        RowLayout {
            spacing: 10
            Layout.fillWidth: true

            Item {
                visible: notif.image !== ""
                width: visible ? 42 : 0; height: 42
                Rectangle {
                    anchors.fill: parent; radius: 8
                    color: bgSecondary; clip: true
                    Image {
                        id: notifImg
                        anchors.fill: parent
                        source: {
                            const img = notif.image
                            if (!img) return ""
                            if (img.startsWith("/")) return "file://" + img
                            if (img.startsWith("data:")) return img
                            if (img.startsWith("file://") || img.startsWith("http"))
                                return img
                            return "image://icon/" + img
                        }
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                    }
                }
            }

            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true

                Text {
                    text: notif.summary || "No title"
                    font.pixelSize: 13; font.weight: Font.SemiBold
                    font.family: "Rubik"
                    color: bgPrimary
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    visible: notif.body !== ""
                    text: notif.body
                    font.pixelSize: 12; font.family: "Rubik"
                    color: bgPrimary
                    wrapMode: Text.WordWrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    lineHeight: 1.35
                }
            }

            Rectangle {
                visible: notif.urgency === "critical" || (notif.urgency + "").toLowerCase().includes("critical")
                width: 7; height: 7; radius: 4
                color: "#ff5f57"
            }
        }

        Row {
            visible: (notif.actions?.length ?? 0) > 0
            spacing: 6
            Layout.fillWidth: true

            Repeater {
                model: notif.actions ?? []
                delegate: Item {
                    required property var modelData
                    implicitWidth: actionLabel.implicitWidth + 20
                    height: 26
                    Rectangle {
                        anchors.fill: parent; radius: 7
                        color: aHover.containsMouse ? Qt.rgba(1,1,1,0.16) : Qt.rgba(1,1,1,0.08)
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Text {
                            id: actionLabel
                            anchors.centerIn: parent
                            text: modelData.text
                            font.pixelSize: 11; font.weight: Font.Medium
                            font.family: "Rubik"; color: "white"
                        }
                    }
                    HoverHandler { id: aHover }
                    TapHandler {
                        onTapped: Notifications.attemptInvokeAction(
                            rowRoot.notif.notificationId, modelData.identifier)
                    }
                }
            }
        }
    }

    function formatTime(ms) {
        if (!ms) return ""
        const d = new Date(ms), now = new Date()
        const diffMin = Math.floor((now - d) / 60000)
        if (diffMin < 1) return "now"
        if (diffMin < 60) return diffMin + "m ago"
        const diffH = Math.floor(diffMin / 60)
        if (diffH < 24) return diffH + "h ago"
        return d.toLocaleDateString(undefined, { month: "short", day: "numeric" })
    }
}
