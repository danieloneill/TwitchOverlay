import QtQuick 2.15

Rectangle {
    id: handle
    width: 32
    height: 32

    function setLimit( which, val )
    {
        if( which === 'minX' )
            dragger.drag.minimumX = val;
        else if( which === 'minY' )
            dragger.drag.minimumY = val;
        else if( which === 'maxX' )
            dragger.drag.maximumX = val;
        else if( which === 'maxY' )
            dragger.drag.maximumY = val;
    }

    property alias moving: dragger.pressed
    radius: 90
    color: 'blue'

    MouseArea {
        id: dragger
        anchors.fill: parent

        drag.target: handle
        drag.axis: Drag.XAndYAxis
        drag.minimumX: 0
        drag.minimumY: 0
        drag.maximumX: overlayRect.width
        drag.maximumY: overlayRect.height
    }
}
