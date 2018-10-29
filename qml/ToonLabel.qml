import QtQuick 2.4
import QtGraphicalEffects 1.0

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

    implicitHeight: labelContainer.implicitHeight
    implicitWidth: labelContainer.implicitWidth

    DropShadow {
        id: dropshadow
        anchors.fill: labelContainer
        clip: parent.clip
        source: labelContainer
        color: '#ff000000'
        radius: 4
        horizontalOffset: 0
        verticalOffset: 0
        samples: 8
        spread: 0.7
        cached: true
    }

    Item {
        id: labelContainer
        anchors.fill: parent
        implicitWidth: label.implicitWidth + dropshadow.radius
        implicitHeight: label.implicitHeight + dropshadow.radius
        Text {
            id: label
            x: dropshadow.radius * 0.5
            y: dropshadow.radius * 0.5
            textFormat: Text.RichText
            wrapMode: Text.Wrap
            width: parent.width - (x*2)
            height: parent.height - (y*2)
            smooth: true
        }

        clip: parent.clip
        visible: parent.visible
    }
/*
    onWidthChanged: {
        console.log("Bottom label ("+text+") width: "+width);
        labelContainer.width = toonLabel.width - dropshadow.radius;
    }
*/
}
