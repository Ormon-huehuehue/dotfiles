import QtQuick

// macOS-style switch
Rectangle {
  id: sw
  property bool on: false
  signal toggled()

  width: 32; height: 18; radius: 9
  color: on ? Style.accent : Qt.rgba(1, 1, 1, 0.16)
  Behavior on color { ColorAnimation { duration: 150 } }

  Rectangle {
    width: 14; height: 14; radius: 7; y: 2; color: "white"
    x: sw.on ? sw.width - width - 2 : 2
    Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
  }
  MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sw.toggled() }
}
