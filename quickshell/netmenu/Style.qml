pragma Singleton
import QtQuick
import Quickshell

// Shared look for the Wi-Fi and Bluetooth dropdowns.
Singleton {
  readonly property color bg: Qt.rgba(28 / 255, 30 / 255, 34 / 255, 0.55)
  readonly property color border: Qt.rgba(1, 1, 1, 0.10)
  readonly property color text: Qt.rgba(235 / 255, 238 / 255, 242 / 255, 0.92)
  readonly property color dim: Qt.rgba(235 / 255, 238 / 255, 242 / 255, 0.45)
  readonly property color hover: Qt.rgba(70 / 255, 125 / 255, 215 / 255, 0.78)
  readonly property color accent: Qt.rgba(70 / 255, 125 / 255, 215 / 255, 0.9)
  readonly property color good: "#4cd964"
  readonly property string font: "Cantarell"
  readonly property string iconFont: "JetBrainsMono Nerd Font"
}
