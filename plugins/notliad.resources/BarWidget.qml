import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "notliad.resources"

  property string cpu: "--"
  property string ram: "--/--GB"

  implicitWidth: label.implicitWidth + Style.space(16)
  implicitHeight: barSize

  Text {
    id: label
    anchors.centerIn: parent
    text: " " + root.cpu + "%   " + root.ram
    color: root.bar.barForeground
    font.family: root.bar.fontFamily
    font.pixelSize: Style.font.body
  }

  Process {
    id: stats
    command: ["bash", "-c", "read cpu u n s i w q x y g gn < /proc/stat; a=$((u+n+s+i+w+q+x+y)); b=$((i+w)); sleep .2; read cpu u n s i w q x y g gn < /proc/stat; c=$((u+n+s+i+w+q+x+y)); d=$((i+w)); awk -v busy=$((c-a-d+b)) -v total=$((c-a)) '/MemTotal/{t=$2}/MemAvailable/{v=$2}END{printf \"%.0f|%.1f/%.0fGB\\n\",100*busy/total,(t-v)/1000000,t/1000000}' /proc/meminfo"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var parts = String(text || "").trim().split("|")
        if (parts.length === 2) {
          root.cpu = parts[0]
          root.ram = parts[1]
        }
      }
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!stats.running) stats.running = true
  }
}
