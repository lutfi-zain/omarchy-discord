import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons

PanelWindow {
  id: root

  property bool active: false
  property string channel: ""
  property real audioPeak: 0

  property real presence: active ? 1.0 : 0.0
  Behavior on presence {
    NumberAnimation {
      duration: root.active ? 220 : 350
      easing.type: root.active ? Easing.OutBack : Easing.InCubic
    }
  }

  visible: presence > 0.005
  anchors { bottom: true }
  margins { bottom: Style.space(28) - (1.0 - presence) * Style.space(16) }
  implicitWidth: pill.implicitWidth + Style.space(36)
  implicitHeight: Style.space(56)
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.namespace: "discord-mic-hud"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
  mask: Region {}

  Item {
    opacity: root.presence
    id: pill
    anchors.centerIn: parent
    implicitWidth: row.implicitWidth + Style.space(32)
    implicitHeight: Style.space(46)
    scale: 0.90 + 0.10 * root.presence

    // Outer breathing aura ring
    Rectangle {
      anchors.centerIn: parent
      width: parent.width + Style.space(10) + root.audioPeak * Style.space(8)
      height: parent.height + Style.space(10) + root.audioPeak * Style.space(8)
      radius: height / 2
      color: "transparent"
      border.color: "#22c55e"
      border.width: Style.space(1)
      opacity: 0.35 + 0.45 * Math.min(1.0, root.audioPeak * 2.0)

      SequentialAnimation on scale {
        loops: Animation.Infinite
        running: root.active
        NumberAnimation { from: 0.98; to: 1.03; duration: 1100; easing.type: Easing.InOutSine }
        NumberAnimation { from: 1.03; to: 0.98; duration: 1100; easing.type: Easing.InOutSine }
      }
    }

    // Main dark frosted capsule
    Rectangle {
      anchors.fill: parent
      radius: height / 2
      color: Util.alpha("#06090e", 0.90)
      border.color: Util.alpha("#22c55e", 0.70 + 0.30 * Math.min(1.0, root.audioPeak * 2.0))
      border.width: Style.space(1.5)

      Row {
        id: row
        anchors.centerIn: parent
        spacing: Style.space(10)

        // Mic icon circle badge
        Rectangle {
          width: Style.space(30)
          height: width
          radius: width / 2
          color: Util.alpha("#22c55e", 0.18 + 0.20 * Math.min(1.0, root.audioPeak * 2.0))
          anchors.verticalCenter: parent.verticalCenter
          scale: 1.0 + 0.15 * Math.min(1.0, root.audioPeak * 2.0)

          Behavior on scale {
            NumberAnimation { duration: 60 }
          }

          Text {
            anchors.centerIn: parent
            text: "󰍬"
            font.family: Style.font.family
            font.pixelSize: Style.space(17)
            color: "#22c55e"
          }
        }

        // Label and audio wave
        Column {
          anchors.verticalCenter: parent.verticalCenter
          spacing: Style.space(3)

          Row {
            spacing: Style.space(6)
            anchors.left: parent.left

            Text {
              text: "MIC OPEN"
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: true
              color: "#22c55e"
              font.letterSpacing: 1.1
            }

            Text {
              visible: root.channel !== ""
              text: "· " + root.channel
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              color: Util.alpha("#ffffff", 0.75)
              elide: Text.ElideRight
              maximumLineCount: 1
            }
          }

          // Dynamic audio equalizer bars
          Row {
            spacing: Style.space(3)
            Repeater {
              model: 5
              Rectangle {
                readonly property real baseH: index === 2 ? 10 : (index % 2 === 1 ? 7 : 5)
                width: Style.space(3)
                height: Style.space(Math.max(3, baseH * (0.4 + root.audioPeak * 1.8)))
                radius: 1.5
                color: "#22c55e"
                anchors.verticalCenter: parent.verticalCenter

                Behavior on height {
                  NumberAnimation { duration: 50 }
                }
              }
            }
          }
        }
      }
    }
  }
}
