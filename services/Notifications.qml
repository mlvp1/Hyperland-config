pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root

    // ── Config (edit these) ───────────────────────────────────────────────────
    property int popupTimeout: 7000
    property string filePath: Qt.resolvedUrl("./notifications_store.json")

    // ── Public state ──────────────────────────────────────────────────────────
    property bool silent: false
    property int unread: 0
    property list<QtObject> list: []
    property var popupList: list.filter((n) => n.popup)
    property bool popupInhibited: silent

    property var latestTimeForApp: ({})
    property var groupsByAppName: groupsForList(root.list)
    property var popupGroupsByAppName: groupsForList(root.popupList)
    property list<string> appNameList: appNameListForGroups(root.groupsByAppName)
    property list<string> popupAppNameList: appNameListForGroups(root.popupGroupsByAppName)

    // ── Signals ───────────────────────────────────────────────────────────────
    signal initDone()
    signal notify(notification: var)
    signal discard(id: int)
    signal discardAll()
    signal timeout(id: var)

    // ── Internal id offset ────────────────────────────────────────────────────
    property int idOffset: 0

    // ── Notif component ───────────────────────────────────────────────────────
    component Notif: QtObject {
        required property int notificationId
        property var notification: null
        property list<var> actions: notification?.actions.map((a) => ({
            identifier: a.identifier,
            text: a.text
        })) ?? []
        property bool popup: false
        property bool isTransient: notification?.hints?.transient ?? false
        property string appIcon: notification?.appIcon ?? ""
        property string appName: notification?.appName ?? ""
        property string body: notification?.body ?? ""
        property string image: notification?.image ?? ""
        property string summary: notification?.summary ?? ""
        property double time: 0
        property string urgency: {
    const u = notification?.urgency
    if (u === NotificationUrgency.Critical) return "critical"
    if (u === NotificationUrgency.Low) return "low"
    return "normal"
}
        property var timer: null

        onNotificationChanged: {
            if (notification === null) root.discardNotification(notificationId)
        }
    }

    component NotifTimer: Timer {
        required property int notificationId
        running: true
        onTriggered: {
            const idx = root.list.findIndex((n) => n.notificationId === notificationId)
            const obj = root.list[idx]
            if (obj?.isTransient) root.discardNotification(notificationId)
            else root.timeoutNotification(notificationId)
            destroy()
        }
    }

    Component { id: notifComp; Notif {} }
    Component { id: timerComp; NotifTimer {} }

    // ── Notification server ───────────────────────────────────────────────────
    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        imageSupported: true
        persistenceSupported: true
        keepOnReload: false

        onNotification: (notification) => {
            notification.tracked = true

            const obj = notifComp.createObject(root, {
                notificationId: notification.id + root.idOffset,
                notification: notification,
                time: Date.now(),
            })

            root.list = [...root.list, obj]

            if (!root.popupInhibited) {
                obj.popup = true
                const interval = notification.expireTimeout < 0
                    ? root.popupTimeout
                    : (notification.expireTimeout === 0 ? root.popupTimeout : notification.expireTimeout)
                obj.timer = timerComp.createObject(root, {
                    notificationId: obj.notificationId,
                    interval: interval,
                })
                root.unread++
            }

            root.notify(obj)
            root._save()
        }
    }

    // ── Grouping helpers ──────────────────────────────────────────────────────
    function groupsForList(lst) {
        const groups = {}
        lst.forEach((n) => {
            if (!groups[n.appName]) {
                groups[n.appName] = { appName: n.appName, appIcon: n.appIcon, notifications: [], time: 0 }
            }
            groups[n.appName].notifications.push(n)
            groups[n.appName].time = Math.max(groups[n.appName].time, n.time)
        })
        return groups
    }

    function appNameListForGroups(groups) {
        return Object.keys(groups).sort((a, b) => groups[b].time - groups[a].time)
    }

    onListChanged: {
        // Rebuild latestTimeForApp
        const map = {}
        root.list.forEach((n) => {
            map[n.appName] = Math.max(map[n.appName] || 0, n.time)
        })
        root.latestTimeForApp = map
        root.groupsByAppName = groupsForList(root.list)
        root.appNameList = appNameListForGroups(root.groupsByAppName)
    }

    onPopupListChanged: {
        root.popupGroupsByAppName = groupsForList(root.popupList)
        root.popupAppNameList = appNameListForGroups(root.popupGroupsByAppName)
    }

    // ── Public API ────────────────────────────────────────────────────────────
    function markAllRead() { root.unread = 0 }

    function discardNotification(id) {
        const idx = root.list.findIndex((n) => n.notificationId === id)
        const serverIdx = server.trackedNotifications.values.findIndex((n) => n.id + root.idOffset === id)
        if (idx !== -1) {
            root.list.splice(idx, 1)
            root.list = root.list.slice(0)
            root._save()
        }
        if (serverIdx !== -1) server.trackedNotifications.values[serverIdx].dismiss()
        root.discard(id)
    }

    function discardAllNotifications() {
        root.list = []
        root._save()
        server.trackedNotifications.values.forEach((n) => n.dismiss())
        root.discardAll()
    }

    function timeoutNotification(id) {
        const idx = root.list.findIndex((n) => n.notificationId === id)
        if (idx !== -1) root.list[idx].popup = false
        root.list = root.list.slice(0)
        root.timeout(id)
    }

    function timeoutAll() {
        root.popupList.forEach((n) => {
            n.popup = false
            root.timeout(n.notificationId)
        })
        root.list = root.list.slice(0)
    }

    function cancelTimeout(id) {
        const idx = root.list.findIndex((n) => n.notificationId === id)
        if (idx !== -1 && root.list[idx].timer) root.list[idx].timer.stop()
    }

    function attemptInvokeAction(id, identifier) {
        const serverIdx = server.trackedNotifications.values.findIndex((n) => n.id + root.idOffset === id)
        if (serverIdx !== -1) {
            const n = server.trackedNotifications.values[serverIdx]
            const action = n.actions.find((a) => a.identifier === identifier)
            if (action) action.invoke()
        }
        root.discardNotification(id)
    }

    // ── Persistence ───────────────────────────────────────────────────────────
    function _notifToJSON(n) {
        return {
            notificationId: n.notificationId,
            actions: [],
            appIcon: n.appIcon,
            appName: n.appName,
            body: n.body,
            image: n.image,
            summary: n.summary,
            time: n.time,
            urgency: n.urgency,
        }
    }

    function _save() {
        fileView.setText(JSON.stringify(root.list.map(_notifToJSON), null, 2))
    }

    FileView {
        id: fileView
        path: root.filePath

        onLoaded: {
            const saved = JSON.parse(fileView.text() || "[]")
            root.list = saved.map((n) => notifComp.createObject(root, {
                notificationId: n.notificationId,
                appIcon: n.appIcon,
                appName: n.appName,
                body: n.body,
                image: n.image,
                summary: n.summary,
                time: n.time,
                urgency: n.urgency,
            }))
            let maxId = 0
            root.list.forEach((n) => { maxId = Math.max(maxId, n.notificationId) })
            root.idOffset = maxId
            root.initDone()
        }

        onLoadFailed: (error) => {
            if (error === FileViewError.FileNotFound) {
                root.list = []
                fileView.setText("[]")
            }
            root.idOffset = 0
            root.initDone()
        }
    }
}
