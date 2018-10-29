import QtQuick 2.7
import QtQuick.Window 2.3

Window {
    title: 'Drag Test'
    //active: true

    width: 800
    height: 600

    id: main

    onRepositioned: {
        console.log("New rect: "+x+"x"+y+"+"+w+"+"+h);
    }

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

    signal repositioned(int x, int y, int w, int h)
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

    Component.onCompleted: {
        setRect( 100, 100, 200, 200 );
    }
}
