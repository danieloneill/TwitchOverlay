import QtQuick 2.15

Item {
    id: toonLabel
    //clip: true
    property alias text: label.text
    property alias font: label.font
    property alias color: label.color
    property alias shadow: dropshadow
    property alias verticalAlignment: label.verticalAlignment
    property alias horizontalAlignment: label.horizontalAlignment
    property bool centered: false

    implicitHeight: label.implicitHeight
    implicitWidth: label.implicitWidth

    DropShadow {
        id: dropshadow
        anchors.fill: label
        clip: parent.clip
        source: label
        color: '#ff000000'
        radius: 3
        horizontalOffset: 0
        verticalOffset: 0
        spread: 0.4
        cached: true
    }

    Text {
        id: label
        width: parent.width
        //anchors.fill: parent
        leftPadding: dropshadow.radius + dropshadow.spread * 2
        topPadding: dropshadow.radius + dropshadow.spread
        textFormat: Text.RichText
        wrapMode: Text.Wrap
        smooth: true
    }
}
