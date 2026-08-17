import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.Commons
import qs.Ui

// Now-playing popup for notliad.media: album art, title/artist/album, and a
// row of basic playback controls (previous / play-pause / next). Rendered in
// a KeyboardPanel (layer-shell) so it works when summoned by keyboard too.
Panel {
  id: root
  moduleName: "notliad.media"
  ipcTarget: "notliad.media"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root

  readonly property color contentForeground: bar ? bar.foreground : Color.foreground
  readonly property string contentFontFamily: bar ? bar.fontFamily : Style.font.family

  readonly property var activePlayer: pickActivePlayer()
  readonly property bool hasMedia: activePlayer !== null && (activePlayer.trackTitle || activePlayer.trackArtist)
  readonly property string playIcon: activePlayer && activePlayer.isPlaying ? "󰏤" : "󰐊"
  readonly property string title: activePlayer ? (activePlayer.trackTitle || "") : ""
  readonly property string artist: activePlayer ? (activePlayer.trackArtist || "") : ""
  readonly property string album: activePlayer && activePlayer.trackAlbum ? activePlayer.trackAlbum : ""
  readonly property string artUrl: activePlayer && activePlayer.trackArtUrl ? activePlayer.trackArtUrl : ""

  function pickActivePlayer() {
    var list = Mpris.players ? Mpris.players.values : []
    var first = null
    for (var i = 0; i < list.length; i++) {
      var p = list[i]
      if (!p) continue
      if (!first) first = p
      if (p.isPlaying) return p
    }
    return first
  }

  function playPause() {
    var p = root.activePlayer
    if (!p) return
    if (p.isPlaying) {
      if (p.canPause) p.pause()
    } else if (p.canPlay) {
      p.play()
    } else if (p.canTogglePlaying && !p.isPlaying) {
      p.pause()
    }
  }

  function nextTrack() {
    var p = root.activePlayer
    if (p && p.canGoNext) p.next()
  }

  function previousTrack() {
    var p = root.activePlayer
    if (p && p.canGoPrevious) p.previous()
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(320))
    contentHeight: panel.fittedContentHeight(contentColumn.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent

      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onActivateRequested: root.playPause()
      onMoveRequested: function(dx, dy) {
        if (dy > 0) root.nextTrack()
        else if (dy < 0) root.previousTrack()
      }
      onTextKey: function(t) {
        if (t === " " || t === "p" || t === "P") root.playPause()
        else if (t === "n" || t === "N") root.nextTrack()
        else if (t === "b" || t === "B") root.previousTrack()
      }

      Column {
        id: contentColumn
        anchors.fill: parent
        spacing: Style.space(10)

        Row {
          spacing: Style.space(10)
          width: parent.width

          BorderSurface {
            width: Style.space(64)
            height: Style.space(64)
            radius: Style.spacing.labelGap
            color: Style.normalFillFor(root.contentForeground, Color.accent)
            borderSpec: Border.controlSpec("normal", root.contentForeground, Color.accent)

            Image {
              anchors.fill: parent
              anchors.margins: Style.space(2)
              fillMode: Image.PreserveAspectCrop
              asynchronous: true
              source: root.artUrl
              visible: source !== ""
            }

            Text {
              anchors.centerIn: parent
              visible: root.artUrl === ""
              text: "󰝚"
              color: root.contentForeground
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.displayLarge
            }
          }

          Column {
            spacing: Style.space(4)
            width: parent.width - Style.space(74)
            anchors.verticalCenter: parent.verticalCenter

            Text {
              text: root.title || "Nothing playing"
              color: root.contentForeground
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.subtitle
              font.bold: true
              elide: Text.ElideRight
              width: parent.width
            }

            Text {
              text: root.artist
              color: Qt.darker(root.contentForeground, 1.3)
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.bodySmall
              elide: Text.ElideRight
              width: parent.width
              visible: text !== ""
            }

            Text {
              text: root.album
              color: Qt.darker(root.contentForeground, 1.6)
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.caption
              elide: Text.ElideRight
              width: parent.width
              visible: text !== ""
            }
          }
        }

        PanelSeparator {
          foreground: root.contentForeground
        }

        Row {
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: Style.space(6)

          Button {
            iconText: "󰒮"
            foreground: root.contentForeground
            horizontalPadding: Style.spacing.controlPaddingX
            verticalPadding: Style.spacing.controlPaddingY
            enabled: root.activePlayer && root.activePlayer.canGoPrevious
            opacity: enabled ? 1.0 : 0.4
            onClicked: root.previousTrack()
          }

          Button {
            iconText: root.playIcon
            foreground: root.contentForeground
            horizontalPadding: Style.spacing.panelGap
            verticalPadding: Style.spacing.controlPaddingY
            iconSize: Style.font.iconLarge
            enabled: root.activePlayer && (root.activePlayer.canTogglePlaying || root.activePlayer.canPlay || root.activePlayer.canPause)
            opacity: enabled ? 1.0 : 0.4
            onClicked: root.playPause()
          }

          Button {
            iconText: "󰒭"
            foreground: root.contentForeground
            horizontalPadding: Style.spacing.controlPaddingX
            verticalPadding: Style.spacing.controlPaddingY
            enabled: root.activePlayer && root.activePlayer.canGoNext
            opacity: enabled ? 1.0 : 0.4
            onClicked: root.nextTrack()
          }
        }
      }
    }
  }
}
