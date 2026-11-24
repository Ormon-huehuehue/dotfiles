import QtQuick

// One menu row: [icon] title / subtitle ............ [trailing glyph]
Rectangle {
  id: row
  property string icon: ""
  property color iconColor: Style.text
  property string title: ""
  property string subtitle: ""
  property string trailing: ""
  property bool interactive: true
  default property alias extra: extraSlot.data
  signal clicked()

  readonly property bool hot: interactive && hover.hovered
  width: parent ? parent.width : 0
  height: (subtitle ? 34 : 26) + extraSlot.childrenRect.height
  radius: 5
  color: hot ? Style.hover : "transparent"
  Behavior on color { ColorAnimation { duration: 90 } }

  Text {
    id: iconText
    visible: row.icon !== ""
    x: 10; y: (row.subtitle ? 34 : 26) / 2 - height / 2
    width: 16
    text: row.icon
    color: row.hot ? "white" : row.iconColor
    font { family: Style.iconFont; pixelSize: 13 }
  }
  Column {
    x: row.icon !== "" ? 32 : 10
    y: (row.subtitle ? 34 : 26) / 2 - height / 2
    width: row.width - x - 30
    Text {
      width: parent.width; elide: Text.ElideRight
      text: row.title
      color: row.hot ? "white" : Style.text
      font { family: Style.font; pixelSize: 11 }
    }
    Text {
      visible: row.subtitle !== ""
      width: parent.width; elide: Text.ElideRight
      text: row.subtitle
      color: row.hot ? Qt.rgba(1, 1, 1, 0.8) : Style.dim
      font { family: Style.font; pixelSize: 9 }
    }
  }
  Text {
    anchors { right: parent.right; rightMargin: 10 }
    y: (row.subtitle ? 34 : 26) / 2 - height / 2
    text: row.trailing
    color: row.hot ? "white" : Style.dim
    font { family: Style.iconFont; pixelSize: 11 }
  }

  HoverHandler { id: hover }
  MouseArea {
    enabled: row.interactive
    width: parent.width; height: row.subtitle ? 34 : 26
    cursorShape: Qt.PointingHandCursor
    onClicked: row.clicked()
  }
  Item {
    id: extraSlot
    y: row.subtitle ? 34 : 26
    width: parent.width
    height: childrenRect.height
  }
}
