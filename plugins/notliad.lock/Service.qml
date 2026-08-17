import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  // Injected by omarchy-shell (the first-party service loader).
  property var shell: null

  property bool lockRequested: false
  property bool lastLocked: false
  property string lastEvent: "init"
  property string lastEventAt: ""

  readonly property bool locked: lockRequested || lastLocked

  function logEvent(event) {
    lastEvent = event
    lastEventAt = new Date().toISOString()
    console.log("omarchy lock " + lastEventAt + " " + event)
  }

  // Launches hyprlock, which takes the ext-session-lock itself. Idempotent:
  // never stack a second instance on top of an active lock.
  function beginLock() {
    if (lockRequested || lastLocked || lockProcess.running) {
      logEvent("lock-already-requested")
      return true
    }

    lockRequested = true
    armBlankTimer()
    logEvent("lock-requested")

    Qt.callLater(function() {
      if (!lockProcess.running) lockProcess.running = true
    })

    return true
  }

  // Polls the compositor for an active session lock. hyprlock implements
  // ext-session-lock, so once it is up, omarchy-hyprland-session-locked
  // reports the session as locked.
  function checkSessionLocked() {
    if (!lockCheckProc.running) lockCheckProc.running = true
  }

  function armBlankTimer() {
    idleBlankTimer.armedAt = Date.now()
    idleBlankTimer.restart()
  }

  function runWake() {
    if (!wakeProcess.running) wakeProcess.running = true
  }

  function runBlank() {
    if (!blankProcess.running) blankProcess.running = true
  }

  Process {
    id: lockProcess
    command: ["bash", "-lc", "hyprlock"]
    onExited: function(exitCode, exitStatus) {
      var wasRequested = root.lockRequested
      root.lockRequested = false
      root.lastLocked = false
      idleBlankTimer.stop()
      root.logEvent(wasRequested ? "unlocked" : "hyprlock-exit " + exitCode)
      root.runWake()
    }
  }

  Process {
    id: lockCheckProc
    command: ["bash", "-c", "omarchy-hyprland-session-locked"]
    onExited: function(exitCode, exitStatus) {
      // 0 locked, 1 unlocked, 2 undetermined. Never report locked on 2.
      root.lastLocked = exitCode === 0
      if (!root.lastLocked && root.lockRequested) {
        root.lockRequested = false
        idleBlankTimer.stop()
        root.logEvent("lock-lost")
      }
    }
  }

  Process {
    id: wakeProcess
    command: ["bash", "-c", "omarchy-system-wake"]
  }

  Process {
    id: blankProcess
    command: ["bash", "-c", "omarchy-brightness-keyboard off; omarchy-brightness-display off"]
  }

  Timer {
    id: idleBlankTimer
    interval: 5000
    repeat: false
    property double armedAt: 0
    onTriggered: {
      // A countdown frozen by suspend fires right after resume, which would
      // blank the freshly woken unlock screen under the user.
      if (Date.now() - armedAt > interval + 2000) {
        root.armBlankTimer()
        return
      }
      if (root.lockRequested) root.runBlank()
    }
  }

  Timer {
    id: lockCheckTimer
    interval: 1000
    repeat: true
    running: root.lockRequested && !root.lastLocked
    onTriggered: root.checkSessionLocked()
  }

  IpcHandler {
    target: "lock"

    function lock(): string {
      if (!root.beginLock()) return "failed"
      return "ok"
    }

    function isLocked(): string {
      root.checkSessionLocked()
      return root.locked ? "true" : "false"
    }

    function status(): string {
      root.checkSessionLocked()
      return JSON.stringify({
        locked: root.locked,
        requested: root.lockRequested,
        pending: false,
        sessionLocked: root.lastLocked,
        secure: root.lastLocked,
        realScreens: 1,
        passwordPam: true,
        fingerprint: false,
        authenticating: false,
        lastEvent: root.lastEvent,
        lastEventAt: root.lastEventAt
      })
    }

    function preview(): string {
      root.beginLock()
      return "ok"
    }

    function hidePreview(): string {
      return "ok"
    }
  }

  Component.onCompleted: {
    checkSessionLocked()
  }
}