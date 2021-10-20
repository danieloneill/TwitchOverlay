import QtQuick 2.7

Item {
    function setRect(x, y, w, h)
    {
        handleTL.x = x - (handleTL.width * 0.5);
        handleTL.y = y - (handleTL.height * 0.5);

        handleTR.x = handleTL.x+w;
        handleTR.y = handleTL.y;

        handleBL.x = handleTL.x;
        handleBL.y = handleTL.y+h;

        handleBR.x = handleTL.x+w;
        handleBR.y = handleTL.y+h;
    }

    signal saved()
    signal repositioned(int overlayX, int overlayY, int overlayW, int overlayH)
    function isRepositioned()
    {
        repositioned( handleTL.x + (handleTL.width * 0.5), handleTL.y + (handleTL.height * 0.5), handleBR.x - handleTL.x, handleBR.y - handleTR.y);
    }

    Rectangle {
        color: '#6600ff00'
        x: handleTL.x + (handleTL.width * 0.5)
        y: handleTL.y + (handleTL.height * 0.5)
        width: handleBR.x - handleBL.x
        height: handleBR.y - handleTR.y

        Text {
            anchors.centerIn: parent
            text: 'Click to save'
            font.pointSize: 24
        }

        MouseArea {
            onClicked: saved();
            anchors.fill: parent
        }
    }

    Handle {
        id: handleTL
        onXChanged: { if( moving ) { handleBL.x = x; } handleTR.setLimit('minX', x+16); }
        onYChanged: { if( moving ) { handleTR.y = y; } handleBL.setLimit('minY', y+16); }
        onMovingChanged: if( !moving ) isRepositioned();
        x: 10
        y: 10
    }
    Handle {
        id: handleTR
        onXChanged: { if( moving ) { handleBR.x = x; } handleTL.setLimit('maxX', x-16); }
        onYChanged: { if( moving ) { handleTL.y = y; } handleBR.setLimit('minY', y+16); }
        onMovingChanged: if( !moving ) isRepositioned();
        x: 50
        y: 10
    }
    Handle {
        id: handleBL
        onXChanged: { if( moving ) { handleTL.x = x; } handleBR.setLimit('minX', x+16); }
        onYChanged: { if( moving ) { handleBR.y = y; } handleTL.setLimit('maxY', y-16); }
        onMovingChanged: if( !moving ) isRepositioned();
        x: 10
        y: 50
    }
    Handle {
        id: handleBR
        onXChanged: { if( moving ) { handleTR.x = x; } handleBL.setLimit('maxX', x-16); }
        onYChanged: { if( moving ) { handleBL.y = y; } handleTR.setLimit('maxY', y-16); }
        onMovingChanged: if( !moving ) isRepositioned();
        x: 50
        y: 50
    }
}
