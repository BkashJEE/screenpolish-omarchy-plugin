// ScreenPolish in the bar: whether a recording is running, how long it has
// been going, and the two things you want mid-take — stop it, or open the
// library — without leaving the window you are recording.
//
// Everything goes through `screenpolish`'s command line, which answers with one
// JSON object per call. The widget keeps no state the app does not already
// have: `status` is the source of truth, and it is polled rather than pushed,
// because a recording can also be started from the app itself, from a global
// shortcut, or from another terminal, and the bar should agree with reality in
// all of those cases.
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarWidget {
    id: root
    moduleName: "bkashjee.screenpolish"

    // From `polish status`: idle, countdown, recording, finalizing, picking.
    property string state: "idle"
    property bool paused: false
    property int startedAt: 0
    property int now: Math.floor(Date.now() / 1000)

    readonly property bool busy: state === "recording" || state === "countdown"
    readonly property bool finishing: state === "finalizing"
    readonly property int elapsed: startedAt > 0 ? Math.max(0, now - startedAt) : 0

    function clock(seconds) {
        const m = Math.floor(seconds / 60)
        const s = seconds % 60
        return m + ":" + (s < 10 ? "0" : "") + s
    }

    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    // A recording is worth knowing about every second; an idle bar is not.
    Timer {
        interval: root.busy ? 1000 : 4000
        running: true
        repeat: true
        onTriggered: {
            root.now = Math.floor(Date.now() / 1000)
            if (!status.running) status.running = true
        }
    }

    function run(args) {
        if (action.running) return
        action.command = ["screenpolish"].concat(args)
        action.running = true
    }

    // Reads the state file the app keeps (status.sh), not `screenpolish status`:
    // that is a full app start, and polling it ran one 15 times a minute and
    // started ScreenPolish again whenever it had been quit.
    Process {
        id: status
        command: ["sh", Qt.resolvedUrl("status.sh").toString().replace("file://", "")]
        running: true
        stdout: SplitParser {
            onRead: function (line) {
                try {
                    const reply = JSON.parse(line)
                    if (!reply.ok) return
                    const s = reply.state || {}
                    root.state = s.status || "idle"
                    root.paused = s.paused === true
                    root.startedAt = s.startedAt ? Math.floor(s.startedAt / 1000) : 0
                } catch (e) {
                    // A malformed line means a newer app and an older widget.
                    // Leaving the last known state alone beats flickering.
                }
            }
        }
        // A non-zero exit means the app is not running, which is not a fault:
        // the widget offers to record, and recording starts the app.
        onExited: function (code) {
            if (code !== 0) {
                root.state = "idle"
                root.startedAt = 0
            }
        }
    }

    Process {
        id: action
        onExited: function () {
            if (!status.running) status.running = true
        }
    }

    BarIconButton {
        id: button
        anchors.fill: parent
        bar: root.bar
        // Record, stop, and the hourglass while the take is being written.
        text: root.finishing ? "󰔟" : (root.busy ? "󰝤" : "󰑊")
        active: root.busy && !root.paused
        tooltipText: root.finishing
            ? "Finishing the recording"
            : root.busy
                ? (root.paused ? "Paused at " + root.clock(root.elapsed) + " — click to stop"
                               : "Recording " + root.clock(root.elapsed) + " — click to stop")
                : "Record the screen — middle click opens the library"
        onPressed: function (b) {
            if (b === Qt.MiddleButton) root.run(["open"])
            else if (root.busy) root.run(["record", "stop"])
            else if (!root.finishing) root.run(["record", "start"])
        }
    }
}
