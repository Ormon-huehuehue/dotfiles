// Wi-Fi + Bluetooth dropdowns for Waybar, sharing one card style and animation.
// Toggle: netmenu-toggle wifi|bluetooth (passes cursor monitor + x). Click outside or Esc closes.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Bluetooth
import Quickshell.Networking

ShellRoot {
  id: shell

  property bool open: false
  property string kind: "wifi"        // "wifi" | "bluetooth"
  property string screenName: ""
  property int anchorX: 0
  property var pskTarget: null        // WifiNetwork awaiting a password

  // ---------- Bluetooth data ----------
  readonly property var adapter: Bluetooth.defaultAdapter
  readonly property var btDevices: {
    var list = (Bluetooth.devices.values || []).filter(d => d.paired || d.connected)
    return list.sort((a, b) => (b.connected - a.connected) || a.name.localeCompare(b.name))
  }

  // ---------- Wi-Fi data ----------
  readonly property var wifiDevice: (Networking.devices.values || []).find(d => d.type === DeviceType.Wifi) || null
  readonly property var wifiNetworks: {
    if (!wifiDevice) return []
    var seen = {}, list = []
    for (const n of (wifiDevice.networks.values || [])) {
      if (!n.name || seen[n.name]) continue
      seen[n.name] = true
      list.push(n)
    }
    return list.sort((a, b) => (b.connected - a.connected) || (b.known - a.known) || (b.signalStrength - a.signalStrength))
  }
  readonly property var wifiKnown: wifiNetworks.filter(n => n.connected || n.known)
  readonly property var wifiOther: wifiNetworks.filter(n => !n.connected && !n.known)

  function signalIcon(s) {
    return s > 0.75 ? "󰤨" : s > 0.5 ? "󰤥" : s > 0.25 ? "󰤢" : "󰤟"
  }
  function needsPsk(n) {
    return [WifiSecurityType.Sae, WifiSecurityType.Wpa2Psk, WifiSecurityType.WpaPsk,
            WifiSecurityType.StaticWep, WifiSecurityType.Wpa3SuiteB192].indexOf(n.security) >= 0
  }
  function isOpen(n) { return n.security === WifiSecurityType.Open || n.security === WifiSecurityType.Owe }
  // `connectionFailed` is a signal; rows record the last failure in `fail`.
  function wifiStatus(n, fail) {
    if (n.state === ConnectionState.Connecting) return "Connecting…"
    if (n.state === ConnectionState.Disconnecting) return "Disconnecting…"
    if (n.connected) return "Connected"
    return fail
  }
  function clickWifi(n) {
    if (n.connected) { n.disconnect(); return }
    if (n.known || isOpen(n)) { n.connect(); return }
    if (needsPsk(n)) { shell.pskTarget = (shell.pskTarget === n ? null : n); return }
    shell.open = false
    Quickshell.execDetached(["nm-connection-editor"])   // enterprise etc.
  }

  onOpenChanged: {
    if (wifiDevice) wifiDevice.scannerEnabled = open && kind === "wifi"
    if (!open) pskTarget = null
  }

  IpcHandler {
    target: "netmenu"
    function toggle(which: string, screen: string, x: int): void {
      if (shell.open && shell.kind === which) { shell.open = false; return }
      shell.kind = which
      shell.screenName = screen
      shell.anchorX = x
      shell.pskTarget = null
      shell.open = true
      if (shell.wifiDevice) shell.wifiDevice.scannerEnabled = which === "wifi"
    }
    function close(): void { shell.open = false }
  }

  PanelWindow {
    id: win

    readonly property int menuWidth: 280
    screen: Quickshell.screens.find(s => s.name === shell.screenName) || Quickshell.screens[0]
    visible: shell.open || card.opacity > 0
    anchors { top: true; left: true }
    margins {
      top: 34
      left: Math.max(8, Math.min(shell.anchorX - menuWidth / 2, (win.screen ? win.screen.width : 1920) - menuWidth - 8))
    }
    implicitWidth: menuWidth
    implicitHeight: Math.min(card.implicitHeight + 12, 640)
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "netmenu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shell.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    HyprlandFocusGrab {
      windows: [win]
      active: shell.open
      onCleared: shell.open = false
    }

    Rectangle {
      id: card

      width: parent.width
      implicitHeight: body.implicitHeight + 10
      height: Math.min(implicitHeight, 628)
      radius: 10
      clip: true
      color: Style.bg
      border.width: 1
      border.color: Style.border
      focus: shell.open
      Keys.onEscapePressed: shell.open = false

      // Open: fade + 6px drop + 97%->100% scale. Close: quicker fade back up.
      opacity: shell.open ? 1 : 0
      Behavior on opacity { NumberAnimation { duration: shell.open ? 160 : 110; easing.type: shell.open ? Easing.OutCubic : Easing.InQuad } }
      transform: [
        Scale { origin.x: card.width / 2; origin.y: 0; xScale: 0.97 + 0.03 * card.opacity; yScale: 0.97 + 0.03 * card.opacity },
        Translate { y: -6 * (1 - card.opacity) }
      ]

      Column {
        id: body
        x: 5; y: 5
        width: parent.width - 10

        // ---------- header ----------
        Item {
          width: parent.width; height: 30
          Text {
            anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
            text: shell.kind === "wifi" ? "Wi-Fi" : "Bluetooth"
            color: Style.text
            font { family: Style.font; pixelSize: 13; bold: true }
          }
          Toggle {
            anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
            on: shell.kind === "wifi" ? Networking.wifiEnabled : (shell.adapter ? shell.adapter.enabled : false)
            onToggled: {
              if (shell.kind === "wifi") Networking.wifiEnabled = !Networking.wifiEnabled
              else if (shell.adapter) shell.adapter.enabled = !shell.adapter.enabled
            }
          }
        }
        Divider {}

        // ---------- Wi-Fi ----------
        Column {
          width: parent.width
          visible: shell.kind === "wifi"

          Text {
            visible: !Networking.wifiEnabled
            leftPadding: 10; topPadding: 2; bottomPadding: 6
            text: "Wi-Fi is off"; color: Style.dim
            font { family: Style.font; pixelSize: 11 }
          }

          SectionLabel { visible: Networking.wifiEnabled && shell.wifiKnown.length > 0; text: "Known networks" }
          Repeater {
            model: Networking.wifiEnabled ? shell.wifiKnown : []
            MenuRow {
              id: knownRow
              required property var modelData
              property string fail: ""
              Connections {
                target: modelData
                function onConnectionFailed(reason) {
                  knownRow.fail = reason === ConnectionFailReason.NoSecrets ? "Wrong password" : "Couldn't connect"
                }
                function onConnectedChanged() { knownRow.fail = "" }
              }
              icon: shell.signalIcon(modelData.signalStrength)
              iconColor: modelData.connected ? Style.text : Style.dim
              title: modelData.name
              subtitle: shell.wifiStatus(modelData, fail)
              trailing: modelData.connected ? "󰄬" : (shell.isOpen(modelData) ? "" : "󰌾")
              onClicked: shell.clickWifi(modelData)
            }
          }

          SectionLabel { visible: Networking.wifiEnabled && shell.wifiOther.length > 0; text: "Other networks" }
          Repeater {
            model: Networking.wifiEnabled ? shell.wifiOther.slice(0, 12) : []
            MenuRow {
              id: otherRow
              required property var modelData
              property string fail: ""
              Connections {
                target: modelData
                function onConnectionFailed(reason) {
                  otherRow.fail = reason === ConnectionFailReason.NoSecrets ? "Wrong password" : "Couldn't connect"
                }
                function onConnectedChanged() { otherRow.fail = "" }
              }
              icon: shell.signalIcon(modelData.signalStrength)
              iconColor: Style.dim
              title: modelData.name
              subtitle: shell.wifiStatus(modelData, fail)
              trailing: shell.isOpen(modelData) ? "" : "󰌾"
              onClicked: shell.clickWifi(modelData)

              // inline password field
              Rectangle {
                visible: shell.pskTarget === otherRow.modelData
                x: 32; width: otherRow.width - 42; height: visible ? 28 : 0
                radius: 5
                color: Qt.rgba(1, 1, 1, 0.08)
                border.width: 1; border.color: psk.activeFocus ? Style.accent : Style.border
                TextInput {
                  id: psk
                  anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                  verticalAlignment: TextInput.AlignVCenter
                  echoMode: TextInput.Password
                  color: Style.text
                  font { family: Style.font; pixelSize: 11 }
                  focus: parent.visible
                  onVisibleChanged: if (visible) { text = ""; forceActiveFocus() }
                  onAccepted: if (text.length > 0) { otherRow.modelData.connectWithPsk(text); shell.pskTarget = null }
                  Keys.onEscapePressed: shell.pskTarget = null
                  Text {
                    visible: !psk.text; anchors.verticalCenter: parent.verticalCenter
                    text: "Password — Enter to join"; color: Style.dim
                    font { family: Style.font; pixelSize: 10 }
                  }
                }
              }
            }
          }

          Text {
            visible: Networking.wifiEnabled && shell.wifiNetworks.length === 0
            leftPadding: 10; topPadding: 2; bottomPadding: 6
            text: "Searching…"; color: Style.dim
            font { family: Style.font; pixelSize: 11 }
          }
        }

        // ---------- Bluetooth ----------
        Column {
          width: parent.width
          visible: shell.kind === "bluetooth"

          Text {
            visible: !shell.adapter || !shell.adapter.enabled
            leftPadding: 10; topPadding: 2; bottomPadding: 6
            text: "Bluetooth is off"; color: Style.dim
            font { family: Style.font; pixelSize: 11 }
          }
          SectionLabel { visible: shell.adapter && shell.adapter.enabled && shell.btDevices.length > 0; text: "Devices" }
          Repeater {
            model: shell.adapter && shell.adapter.enabled ? shell.btDevices : []
            MenuRow {
              required property var modelData
              readonly property bool busy: modelData.state === BluetoothDeviceState.Connecting
                || modelData.state === BluetoothDeviceState.Disconnecting
              icon: "󰂯"
              iconColor: modelData.connected ? Style.text : Style.dim
              title: modelData.name
              subtitle: busy ? (modelData.connected ? "Disconnecting…" : "Connecting…")
                : modelData.connected
                  ? "Connected" + (modelData.batteryAvailable ? " · " + Math.round(modelData.battery * 100) + "%" : "")
                  : "Not connected"
              trailing: modelData.connected ? "󰄬" : ""
              onClicked: if (!busy) modelData.connected ? modelData.disconnect() : modelData.connect()
            }
          }
        }

        Divider {}
        MenuRow {
          title: shell.kind === "wifi" ? "Network Settings…" : "Bluetooth Settings…"
          onClicked: {
            shell.open = false
            Quickshell.execDetached([shell.kind === "wifi" ? "nm-connection-editor" : "blueman-manager"])
          }
        }
      }
    }
  }
}
