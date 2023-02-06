import QtQuick 2.15
import QtQuick.Controls 2.15

Slider {
    id: control
    property alias text: label.text
    property real textScale: 1.0

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 26
        implicitHeight: 26
        radius: 13
        color: control.pressed ? "#f0f0f0" : "#f6f6f6"
        border.color: "#bdbebf"

        Text {
            id: label
            anchors.centerIn: parent
            font.pixelSize: ( parent.height * 0.4 ) * textScale
            color: 'black'
        }
    }
}
