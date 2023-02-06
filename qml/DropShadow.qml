import QtQuick 2.15

Item {
    id: dropShadowWrapper
    property Item source
    property color color: 'black'
    property real radius: 0
    property real horizontalOffset: 0
    property real verticalOffset: 0
    property real spread: 0.5
    property bool cached: true

    Loader {
        id: loader
        anchors.fill: parent
        source: qVersion.substring(0,2) === '6.' ? 'DropShadow6.qml' : 'DropShadow5.qml'

        onLoaded: dropShadowWrapper.updateItem();
    }

    onSourceChanged: updateItem();
    onColorChanged: updateItem();
    onRadiusChanged: updateItem();
    onHorizontalOffsetChanged: updateItem();
    onVerticalOffsetChanged: updateItem();
    onSpreadChanged: updateItem();
    onCachedChanged: updateItem();

    function updateItem() {
        if( !loader.item )
            return;

        loader.item.source = dropShadowWrapper.source;
        loader.item.color = dropShadowWrapper.color;
        loader.item.radius = dropShadowWrapper.radius;
        loader.item.horizontalOffset = dropShadowWrapper.horizontalOffset;
        loader.item.verticalOffset = dropShadowWrapper.verticalOffset;
        loader.item.spread = dropShadowWrapper.spread;
        loader.item.cached = dropShadowWrapper.cached;
    }
}
